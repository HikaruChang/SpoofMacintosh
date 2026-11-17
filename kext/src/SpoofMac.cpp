// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0
// SpoofMac.cpp — Dynamic IOPlatformExpertDevice property spoofer for Apple Silicon Macs.
// Snapshots factory properties before any mutation, supports runtime updates across
// standard and arbitrary custom IORegistry properties (root-only), and restores factory
// state cleanly on ResetToFactory or stop().

#include <IOKit/IOService.h>
#include <IOKit/IOLib.h>
#include <IOKit/IOLocks.h>
#include <IOKit/IOUserClient.h>
#include <kern/task.h>
#include <pexpert/pexpert.h>
#include <libkern/c++/OSBoolean.h>
#include <libkern/c++/OSCollectionIterator.h>
#include <libkern/c++/OSData.h>
#include <libkern/c++/OSDictionary.h>
#include <libkern/c++/OSString.h>
#include <libkern/c++/OSSymbol.h>
#include <string.h>

enum SpoofEncoding {
    kSpoofEncCString      = 0, // OSData NUL-terminated C string (strlen + 1)
    kSpoofEncPad32        = 1, // OSData fixed 32-byte zero-padded buffer
    kSpoofEncPad64        = 2, // OSData fixed 64-byte zero-padded buffer
    kSpoofEncRaw          = 3, // OSData raw ASCII bytes without trailing NUL
    kSpoofEncOSString     = 4, // OSString (used by IOPlatformSerialNumber / IOPlatformUUID)
    kSpoofEncMultiCString = 5, // OSData comma-separated NUL-terminated strings (compatible)
    kSpoofEncHex          = 6  // OSData decoded from hexadecimal string
};

struct SpoofFieldSpec {
    const char *cfgKey;
    const char *provKey;
    const char *origMirrorKey;
    const char *activeKey;
    SpoofEncoding encoding;
};

static const SpoofFieldSpec kSpoofFields[] = {
    { "SpoofModel",            "model",                   "orig-model",                   "active-model",                   kSpoofEncCString  },
    { "SpoofModelNumber",      "model-number",            "orig-model-number",            "active-model-number",            kSpoofEncPad32    },
    { "SpoofRegionInfo",       "region-info",             "orig-region-info",             "active-region-info",             kSpoofEncPad32    },
    { "SpoofRegulatoryModel",  "regulatory-model-number", "orig-regulatory-model-number", "active-regulatory-model-number", kSpoofEncPad32    },
    { "SpoofTargetType",       "target-type",             "orig-target-type",             "active-target-type",             kSpoofEncCString  },
    { "SpoofTargetSubType",    "target-sub-type",         "orig-target-sub-type",         "active-target-sub-type",         kSpoofEncCString  },
    { "SpoofCountryOfOrigin",  "country-of-origin",       "orig-country-of-origin",       "active-country-of-origin",       kSpoofEncRaw      },
    { "SpoofPlatformName",     "platform-name",           "orig-platform-name",           "active-platform-name",           kSpoofEncPad32    },
    { "SpoofSerialNumber",     "IOPlatformSerialNumber",  "orig-IOPlatformSerialNumber",  "active-IOPlatformSerialNumber",  kSpoofEncOSString },
    { "SpoofRawSerialData",    "serial-number",           "orig-serial-number",           "active-serial-number",           kSpoofEncPad32    },
    { "SpoofUUID",             "IOPlatformUUID",          "orig-IOPlatformUUID",          "active-IOPlatformUUID",          kSpoofEncOSString },
    { "SpoofMLB",              "mlb-serial-number",       "orig-mlb-serial-number",       "active-mlb-serial-number",       kSpoofEncPad32    },
    { "SpoofManufacturer",     "manufacturer",            "orig-manufacturer",            "active-manufacturer",            kSpoofEncCString  },
    { "SpoofModelConfig",      "model-config",            "orig-model-config",            "active-model-config",            kSpoofEncRaw      },
    { "SpoofConfigNumber",     "config-number",           "orig-config-number",           "active-config-number",           kSpoofEncPad64    },
    { "SpoofDeviceType",       "device_type",             "orig-device_type",             "active-device_type",             kSpoofEncCString  },
    { "SpoofSecureRootPrefix", "secure-root-prefix",      "orig-secure-root-prefix",      "active-secure-root-prefix",      kSpoofEncCString  },
    { "SpoofNodeName",         "name",                    "orig-name",                    "active-name",                    kSpoofEncCString  },
};

static constexpr unsigned int kSpoofFieldCount = sizeof(kSpoofFields) / sizeof(kSpoofFields[0]);
static constexpr const char *kOriginalsProviderKey = "spoofmac-originals";
static constexpr const char *kCompatibleKey = "compatible";
static constexpr const char *kOrigCompatibleKey = "orig-compatible";

static int hexNibble(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

static SpoofEncoding parseEncodingName(const char *name)
{
    if (!name) return kSpoofEncCString;
    if (strcmp(name, "osstring") == 0) return kSpoofEncOSString;
    if (strcmp(name, "pad32") == 0)    return kSpoofEncPad32;
    if (strcmp(name, "pad64") == 0)    return kSpoofEncPad64;
    if (strcmp(name, "raw") == 0)      return kSpoofEncRaw;
    if (strcmp(name, "multicstring") == 0) return kSpoofEncMultiCString;
    if (strcmp(name, "hex") == 0)      return kSpoofEncHex;
    return kSpoofEncCString;
}

class com_spoofmacintosh_SpoofMac : public IOService {
    OSDeclareDefaultStructors(com_spoofmacintosh_SpoofMac)

private:
    IOLock *fLock;
    IOService *fProvider;
    OSDictionary *fOriginals;
    OSDictionary *fActiveCustomKeys;
    bool fUpdateCompatible;

    bool snapshotOriginals(IOService *provider);
    void ensureOriginalSavedLocked(const char *provKey, const char *origMirrorKey = nullptr);
    void restoreSinglePropertyLocked(const char *provKey);
    void restoreAllOriginalsLocked();
    void updateCompatibleLocked();
    void applyCustomPropertiesLocked(OSDictionary *customDict);
    void applyConfigLocked(OSDictionary *cfg);
    OSObject *encodeValue(const char *str, SpoofEncoding encoding);
    size_t readDataCStringLen(OSData *data, char *outBuf, size_t bufCap);

public:
    virtual bool init(OSDictionary *dictionary = nullptr) override;
    virtual void free() override;
    virtual bool start(IOService *provider) override;
    virtual void stop(IOService *provider) override;
    virtual IOReturn setProperties(OSObject *properties) override;
};

OSDefineMetaClassAndStructors(com_spoofmacintosh_SpoofMac, IOService)

bool com_spoofmacintosh_SpoofMac::init(OSDictionary *dictionary)
{
    if (!IOService::init(dictionary)) {
        return false;
    }
    fLock = IOLockAlloc();
    if (!fLock) {
        return false;
    }
    fActiveCustomKeys = OSDictionary::withCapacity(8);
    if (!fActiveCustomKeys) {
        IOLockFree(fLock);
        fLock = nullptr;
        return false;
    }
    fProvider = nullptr;
    fOriginals = nullptr;
    fUpdateCompatible = true;
    return true;
}

void com_spoofmacintosh_SpoofMac::free()
{
    OSSafeReleaseNULL(fOriginals);
    OSSafeReleaseNULL(fActiveCustomKeys);
    if (fLock) {
        IOLockFree(fLock);
        fLock = nullptr;
    }
    IOService::free();
}

OSObject *com_spoofmacintosh_SpoofMac::encodeValue(const char *str, SpoofEncoding encoding)
{
    if (!str) {
        return nullptr;
    }

    size_t len = strnlen(str, 512);
    if (len == 0) {
        return nullptr;
    }

    if (encoding == kSpoofEncOSString) {
        return OSString::withCString(str);
    }

    if (encoding == kSpoofEncPad32) {
        unsigned char buf[32];
        memset(buf, 0, sizeof(buf));
        size_t copyLen = len < 31 ? len : 31;
        memcpy(buf, str, copyLen);
        return OSData::withBytes(buf, sizeof(buf));
    }

    if (encoding == kSpoofEncPad64) {
        unsigned char buf[64];
        memset(buf, 0, sizeof(buf));
        size_t copyLen = len < 63 ? len : 63;
        memcpy(buf, str, copyLen);
        return OSData::withBytes(buf, sizeof(buf));
    }

    if (encoding == kSpoofEncCString) {
        unsigned char buf[256];
        size_t copyLen = len < 254 ? len : 254;
        memcpy(buf, str, copyLen);
        buf[copyLen] = '\0';
        return OSData::withBytes(buf, static_cast<unsigned int>(copyLen + 1));
    }

    if (encoding == kSpoofEncMultiCString) {
        unsigned char buf[512];
        size_t outIdx = 0;
        size_t i = 0;
        while (i < len) {
            while (i < len && (str[i] == ',' || str[i] == ' ' || str[i] == '\t')) {
                i++;
            }
            if (i >= len) break;
            size_t segStart = i;
            while (i < len && str[i] != ',') {
                i++;
            }
            size_t segEnd = i;
            while (segEnd > segStart && (str[segEnd - 1] == ' ' || str[segEnd - 1] == '\t')) {
                segEnd--;
            }
            size_t segLen = segEnd - segStart;
            if (segLen > 0) {
                if (outIdx + segLen + 1 > sizeof(buf)) {
                    break;
                }
                memcpy(buf + outIdx, str + segStart, segLen);
                buf[outIdx + segLen] = '\0';
                outIdx += segLen + 1;
            }
        }
        if (outIdx == 0) {
            return nullptr;
        }
        return OSData::withBytes(buf, static_cast<unsigned int>(outIdx));
    }

    if (encoding == kSpoofEncHex) {
        unsigned char buf[256];
        size_t outLen = 0;
        int highNibble = -1;
        for (size_t i = 0; i < len; i++) {
            char c = str[i];
            if (c == ' ' || c == '\t' || c == ':' || c == '-') {
                continue;
            }
            if (c == '0' && i + 1 < len && (str[i + 1] == 'x' || str[i + 1] == 'X') && highNibble == -1) {
                i++;
                continue;
            }
            int nib = hexNibble(c);
            if (nib < 0) {
                return nullptr;
            }
            if (highNibble < 0) {
                highNibble = nib;
            } else {
                if (outLen >= sizeof(buf)) {
                    return nullptr;
                }
                buf[outLen++] = static_cast<unsigned char>((highNibble << 4) | nib);
                highNibble = -1;
            }
        }
        if (highNibble >= 0 || outLen == 0) {
            return nullptr;
        }
        return OSData::withBytes(buf, static_cast<unsigned int>(outLen));
    }

    // kSpoofEncRaw: exact ASCII bytes without trailing NUL
    return OSData::withBytes(str, static_cast<unsigned int>(len));
}

size_t com_spoofmacintosh_SpoofMac::readDataCStringLen(OSData *data, char *outBuf, size_t bufCap)
{
    if (!data || !outBuf || bufCap == 0) {
        return 0;
    }
    const char *bytes = static_cast<const char *>(data->getBytesNoCopy());
    unsigned int totalLen = data->getLength();
    if (!bytes || totalLen == 0) {
        outBuf[0] = '\0';
        return 0;
    }
    size_t actualLen = strnlen(bytes, totalLen);
    if (actualLen >= bufCap) {
        actualLen = bufCap - 1;
    }
    memcpy(outBuf, bytes, actualLen);
    outBuf[actualLen] = '\0';
    return actualLen;
}

void com_spoofmacintosh_SpoofMac::ensureOriginalSavedLocked(const char *provKey, const char *origMirrorKey)
{
    if (!fOriginals || !fProvider || !provKey || provKey[0] == '\0') {
        return;
    }
    if (fOriginals->getObject(provKey) != nullptr) {
        return;
    }

    OSObject *orig = fProvider->getProperty(provKey);
    if (!orig) {
        fOriginals->setObject(provKey, kOSBooleanFalse);
        return;
    }

    if (OSData *data = OSDynamicCast(OSData, orig)) {
        OSData *copy = OSData::withData(data);
        if (copy) {
            fOriginals->setObject(provKey, copy);
            if (origMirrorKey) {
                setProperty(origMirrorKey, copy);
            }
            copy->release();
        }
    } else if (OSString *str = OSDynamicCast(OSString, orig)) {
        OSString *copy = OSString::withString(str);
        if (copy) {
            fOriginals->setObject(provKey, copy);
            if (origMirrorKey) {
                setProperty(origMirrorKey, copy);
            }
            copy->release();
        }
    } else {
        fOriginals->setObject(provKey, orig);
        if (origMirrorKey) {
            setProperty(origMirrorKey, orig);
        }
    }
}

bool com_spoofmacintosh_SpoofMac::snapshotOriginals(IOService *provider)
{
    if (!provider) {
        return false;
    }

    OSDictionary *existing = OSDynamicCast(OSDictionary, provider->getProperty(kOriginalsProviderKey));
    if (existing) {
        OSSafeReleaseNULL(fOriginals);
        existing->retain();
        fOriginals = existing;
    } else {
        OSDictionary *snap = OSDictionary::withCapacity(kSpoofFieldCount + 8);
        if (!snap) {
            return false;
        }
        provider->setProperty(kOriginalsProviderKey, snap);
        OSSafeReleaseNULL(fOriginals);
        fOriginals = snap; // keep initial retain
    }

    for (unsigned int i = 0; i < kSpoofFieldCount; i++) {
        ensureOriginalSavedLocked(kSpoofFields[i].provKey, kSpoofFields[i].origMirrorKey);
        OSObject *val = fOriginals->getObject(kSpoofFields[i].provKey);
        if (val && val != kOSBooleanFalse) {
            setProperty(kSpoofFields[i].origMirrorKey, val);
        }
    }
    ensureOriginalSavedLocked(kCompatibleKey, kOrigCompatibleKey);
    OSObject *compatVal = fOriginals->getObject(kCompatibleKey);
    if (compatVal && compatVal != kOSBooleanFalse) {
        setProperty(kOrigCompatibleKey, compatVal);
    }

    return true;
}

void com_spoofmacintosh_SpoofMac::restoreSinglePropertyLocked(const char *provKey)
{
    if (!fProvider || !fOriginals || !provKey) {
        return;
    }
    OSObject *orig = fOriginals->getObject(provKey);
    if (!orig || orig == kOSBooleanFalse) {
        fProvider->removeProperty(provKey);
    } else {
        fProvider->setProperty(provKey, orig);
    }
}

void com_spoofmacintosh_SpoofMac::restoreAllOriginalsLocked()
{
    if (!fProvider) {
        return;
    }

    if (fOriginals) {
        OSCollectionIterator *iter = OSCollectionIterator::withCollection(fOriginals);
        if (iter) {
            while (OSSymbol *keySym = OSDynamicCast(OSSymbol, iter->getNextObject())) {
                restoreSinglePropertyLocked(keySym->getCStringNoCopy());
            }
            iter->release();
        }
    }

    for (unsigned int i = 0; i < kSpoofFieldCount; i++) {
        removeProperty(kSpoofFields[i].activeKey);
    }
    removeProperty("active-compatible");
    removeProperty("active-custom-properties");
    if (fActiveCustomKeys) {
        fActiveCustomKeys->flushCollection();
    }
    setProperty("SpoofActive", kOSBooleanFalse);
    IOLog("SpoofMac: restored all factory properties\n");
}

void com_spoofmacintosh_SpoofMac::updateCompatibleLocked()
{
    if (!fProvider) {
        return;
    }

    bool modelSpoofed = (getProperty("active-model") != nullptr);
    bool subTypeSpoofed = (getProperty("active-target-sub-type") != nullptr);

    if (!fUpdateCompatible || (!modelSpoofed && !subTypeSpoofed)) {
        restoreSinglePropertyLocked(kCompatibleKey);
        removeProperty("active-compatible");
        return;
    }

    char subTypeBuf[128];
    char modelBuf[128];
    OSData *subData = OSDynamicCast(OSData, fProvider->getProperty("target-sub-type"));
    OSData *modelData = OSDynamicCast(OSData, fProvider->getProperty("model"));
    size_t subLen = readDataCStringLen(subData, subTypeBuf, sizeof(subTypeBuf));
    size_t modelLen = readDataCStringLen(modelData, modelBuf, sizeof(modelBuf));

    if (subLen == 0 || modelLen == 0) {
        return;
    }

    static constexpr const char kArmTag[] = "AppleARM";
    size_t armLen = sizeof(kArmTag) - 1;
    size_t totalBytes = (subLen + 1) + (modelLen + 1) + (armLen + 1);

    unsigned char buf[320];
    if (totalBytes > sizeof(buf)) {
        return;
    }

    size_t offset = 0;
    memcpy(buf + offset, subTypeBuf, subLen);
    buf[offset + subLen] = '\0';
    offset += subLen + 1;

    memcpy(buf + offset, modelBuf, modelLen);
    buf[offset + modelLen] = '\0';
    offset += modelLen + 1;

    memcpy(buf + offset, kArmTag, armLen);
    buf[offset + armLen] = '\0';
    offset += armLen + 1;

    OSData *compatData = OSData::withBytes(buf, static_cast<unsigned int>(offset));
    if (compatData) {
        fProvider->setProperty(kCompatibleKey, compatData);
        setProperty("active-compatible", compatData);
        compatData->release();
    }
}

void com_spoofmacintosh_SpoofMac::applyCustomPropertiesLocked(OSDictionary *customDict)
{
    if (!fProvider || !customDict || !fActiveCustomKeys) {
        return;
    }

    // Restore previously spoofed custom keys that are removed in the new dictionary
    OSCollectionIterator *prevIter = OSCollectionIterator::withCollection(fActiveCustomKeys);
    if (prevIter) {
        while (OSSymbol *prevKey = OSDynamicCast(OSSymbol, prevIter->getNextObject())) {
            const char *k = prevKey->getCStringNoCopy();
            if (k && customDict->getObject(k) == nullptr) {
                restoreSinglePropertyLocked(k);
            }
        }
        prevIter->release();
    }
    fActiveCustomKeys->flushCollection();

    OSCollectionIterator *iter = OSCollectionIterator::withCollection(customDict);
    if (iter) {
        while (OSSymbol *keySym = OSDynamicCast(OSSymbol, iter->getNextObject())) {
            const char *provKey = keySym->getCStringNoCopy();
            if (!provKey || provKey[0] == '\0' || strcmp(provKey, kOriginalsProviderKey) == 0) {
                continue;
            }
            OSObject *entryObj = customDict->getObject(keySym);
            const char *valStr = nullptr;
            SpoofEncoding enc = kSpoofEncCString;

            if (OSDictionary *entryDict = OSDynamicCast(OSDictionary, entryObj)) {
                OSString *typeObj = OSDynamicCast(OSString, entryDict->getObject("Type"));
                OSString *valObj = OSDynamicCast(OSString, entryDict->getObject("Value"));
                if (typeObj) {
                    enc = parseEncodingName(typeObj->getCStringNoCopy());
                }
                if (valObj) {
                    valStr = valObj->getCStringNoCopy();
                }
            } else if (OSString *plainStr = OSDynamicCast(OSString, entryObj)) {
                valStr = plainStr->getCStringNoCopy();
            }

            if (!valStr || valStr[0] == '\0') {
                restoreSinglePropertyLocked(provKey);
                continue;
            }

            ensureOriginalSavedLocked(provKey);
            OSObject *encoded = encodeValue(valStr, enc);
            if (encoded) {
                fProvider->setProperty(provKey, encoded);
                encoded->release();
                OSString *summary = OSString::withCString(valStr);
                if (summary) {
                    fActiveCustomKeys->setObject(provKey, summary);
                    summary->release();
                }
            }
        }
        iter->release();
    }

    if (fActiveCustomKeys->getCount() > 0) {
        setProperty("active-custom-properties", fActiveCustomKeys);
    } else {
        removeProperty("active-custom-properties");
    }
}

void com_spoofmacintosh_SpoofMac::applyConfigLocked(OSDictionary *cfg)
{
    if (!fProvider || !cfg) {
        return;
    }

    if (cfg->getObject("ResetToFactory") == kOSBooleanTrue) {
        restoreAllOriginalsLocked();
        return;
    }

    OSObject *updObj = cfg->getObject("UpdateCompatible");
    if (updObj == kOSBooleanTrue) {
        fUpdateCompatible = true;
    } else if (updObj == kOSBooleanFalse) {
        fUpdateCompatible = false;
    }
    setProperty("UpdateCompatible", fUpdateCompatible ? kOSBooleanTrue : kOSBooleanFalse);

    OSString *explicitRawSn = OSDynamicCast(OSString, cfg->getObject("SpoofRawSerialData"));
    bool hasExplicitRawSn = (explicitRawSn != nullptr &&
                             explicitRawSn->getCStringNoCopy() != nullptr &&
                             explicitRawSn->getCStringNoCopy()[0] != '\0');

    for (unsigned int i = 0; i < kSpoofFieldCount; i++) {
        OSObject *val = cfg->getObject(kSpoofFields[i].cfgKey);
        if (!val) {
            continue;
        }
        OSString *str = OSDynamicCast(OSString, val);
        if (!str) {
            continue;
        }
        const char *cstr = str->getCStringNoCopy();
        if (!cstr || cstr[0] == '\0') {
            restoreSinglePropertyLocked(kSpoofFields[i].provKey);
            removeProperty(kSpoofFields[i].activeKey);
        } else {
            ensureOriginalSavedLocked(kSpoofFields[i].provKey, kSpoofFields[i].origMirrorKey);
            OSObject *encoded = encodeValue(cstr, kSpoofFields[i].encoding);
            if (encoded) {
                fProvider->setProperty(kSpoofFields[i].provKey, encoded);
                encoded->release();
                setProperty(kSpoofFields[i].activeKey, str);
            }
        }
    }

    // Mirror IOPlatformSerialNumber -> serial-number (32-byte padded) when SpoofRawSerialData is omitted/empty
    OSString *snStr = OSDynamicCast(OSString, cfg->getObject("SpoofSerialNumber"));
    if (snStr && !hasExplicitRawSn) {
        const char *snCstr = snStr->getCStringNoCopy();
        if (!snCstr || snCstr[0] == '\0') {
            restoreSinglePropertyLocked("serial-number");
            removeProperty("active-serial-number");
        } else {
            ensureOriginalSavedLocked("serial-number", "orig-serial-number");
            OSObject *rawSn = encodeValue(snCstr, kSpoofEncPad32);
            if (rawSn) {
                fProvider->setProperty("serial-number", rawSn);
                rawSn->release();
                setProperty("active-serial-number", snStr);
            }
        }
    }

    // Custom comma-separated compatible array or automatic <target-sub-type>\0<model>\0AppleARM\0
    OSString *customCompat = OSDynamicCast(OSString, cfg->getObject("SpoofCompatible"));
    if (customCompat && customCompat->getCStringNoCopy() && customCompat->getCStringNoCopy()[0] != '\0') {
        ensureOriginalSavedLocked(kCompatibleKey, kOrigCompatibleKey);
        OSObject *compatEncoded = encodeValue(customCompat->getCStringNoCopy(), kSpoofEncMultiCString);
        if (compatEncoded) {
            fProvider->setProperty(kCompatibleKey, compatEncoded);
            setProperty("active-compatible", compatEncoded);
            compatEncoded->release();
        }
    } else {
        updateCompatibleLocked();
    }

    if (OSDictionary *customDict = OSDynamicCast(OSDictionary, cfg->getObject("CustomProperties"))) {
        applyCustomPropertiesLocked(customDict);
    }

    bool anyActive = (getProperty("active-compatible") != nullptr) ||
                     (fActiveCustomKeys && fActiveCustomKeys->getCount() > 0);
    if (!anyActive) {
        for (unsigned int i = 0; i < kSpoofFieldCount; i++) {
            if (getProperty(kSpoofFields[i].activeKey) != nullptr) {
                anyActive = true;
                break;
            }
        }
    }
    setProperty("SpoofActive", anyActive ? kOSBooleanTrue : kOSBooleanFalse);
    IOLog("SpoofMac: applied configuration (active=%d)\n", anyActive ? 1 : 0);
}

bool com_spoofmacintosh_SpoofMac::start(IOService *provider)
{
    if (!IOService::start(provider)) {
        return false;
    }

    IOLockLock(fLock);
    fProvider = provider;

    if (!snapshotOriginals(provider)) {
        fProvider = nullptr;
        IOLockUnlock(fLock);
        return false;
    }

    int spoofOff = 0;
    if (PE_parse_boot_argn("spoof_off", &spoofOff, sizeof(spoofOff)) && spoofOff != 0) {
        setProperty("SpoofActive", kOSBooleanFalse);
        setProperty("SpoofBypassedByBootArg", kOSBooleanTrue);
        IOLog("SpoofMac: bypassed via spoof_off boot-arg\n");
        IOLockUnlock(fLock);
        registerService();
        return true;
    }

    OSDictionary *initCfg = OSDictionary::withCapacity(kSpoofFieldCount + 4);
    if (initCfg) {
        OSObject *updProp = getProperty("UpdateCompatible");
        if (updProp) {
            initCfg->setObject("UpdateCompatible", updProp);
        }

        for (unsigned int i = 0; i < kSpoofFieldCount; i++) {
            OSString *propStr = OSDynamicCast(OSString, getProperty(kSpoofFields[i].cfgKey));
            if (propStr) {
                initCfg->setObject(kSpoofFields[i].cfgKey, propStr);
            }
        }

        // Optional boot-arg overrides for recovery / early boot testing
        static const struct {
            const char *bootArg;
            const char *cfgKey;
        } kBootOverrides[] = {
            { "spoof_model",     "SpoofModel" },
            { "spoof_mnum",      "SpoofModelNumber" },
            { "spoof_region",    "SpoofRegionInfo" },
            { "spoof_regnum",    "SpoofRegulatoryModel" },
            { "spoof_target",    "SpoofTargetType" },
            { "spoof_subtarget", "SpoofTargetSubType" },
            { "spoof_country",   "SpoofCountryOfOrigin" },
            { "spoof_platform",  "SpoofPlatformName" },
            { "spoof_sn",        "SpoofSerialNumber" },
            { "spoof_uuid",      "SpoofUUID" },
            { "spoof_mlb",       "SpoofMLB" },
        };
        for (unsigned int i = 0; i < sizeof(kBootOverrides) / sizeof(kBootOverrides[0]); i++) {
            char argBuf[128];
            memset(argBuf, 0, sizeof(argBuf));
            if (PE_parse_boot_arg_str(kBootOverrides[i].bootArg, argBuf, sizeof(argBuf)) && argBuf[0] != '\0') {
                OSString *bootStr = OSString::withCString(argBuf);
                if (bootStr) {
                    initCfg->setObject(kBootOverrides[i].cfgKey, bootStr);
                    bootStr->release();
                }
            }
        }

        applyConfigLocked(initCfg);
        initCfg->release();
    }

    IOLockUnlock(fLock);
    registerService();
    return true;
}

void com_spoofmacintosh_SpoofMac::stop(IOService *provider)
{
    IOLockLock(fLock);
    restoreAllOriginalsLocked();
    fProvider = nullptr;
    IOLockUnlock(fLock);
    IOService::stop(provider);
}

IOReturn com_spoofmacintosh_SpoofMac::setProperties(OSObject *properties)
{
    if (IOUserClient::clientHasPrivilege(current_task(), kIOClientPrivilegeAdministrator) != kIOReturnSuccess) {
        return kIOReturnNotPrivileged;
    }

    OSDictionary *dict = OSDynamicCast(OSDictionary, properties);
    if (!dict) {
        return kIOReturnBadArgument;
    }

    IOLockLock(fLock);
    if (!fProvider) {
        IOLockUnlock(fLock);
        return kIOReturnNotReady;
    }
    applyConfigLocked(dict);
    IOLockUnlock(fLock);

    return kIOReturnSuccess;
}
