#!/bin/bash
#
# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0
#
# install.sh — SpoofMacintosh 安裝 / 管理 / 診斷 / 卸載腳本
#
# 用法:
#   sudo ./install.sh install     安裝或升級 SpoofMac.kext、CLI 與開機 LaunchDaemon（預設）
#   sudo ./install.sh status      查看系統狀態與多領域資格
#   sudo ./install.sh apply ...   轉發參數至 spoofmac apply（即時切換機型/地區）
#   sudo ./install.sh reset       立即還原至原廠硬體屬性
#   sudo ./install.sh refresh     強制重算 os_eligibility 與 AI 守護程序
#   sudo ./install.sh diagnose    輸出純文字診斷報告（不含序號與 UUID）
#   sudo ./install.sh uninstall   完整卸載並恢復原廠硬體識別
#

set -uo pipefail
AMFI_CHANGED=0

if [ -t 1 ]; then
  R=$'\033[0;31m'; G=$'\033[0;32m'; Y=$'\033[1;33m'; B=$'\033[0;34m'; C=$'\033[0;36m'; W=$'\033[1m'; N=$'\033[0m'
else
  R=''; G=''; Y=''; B=''; C=''; W=''; N=''
fi
info(){ printf '%s==>%s %s\n' "$B" "$N" "$1"; }
ok(){   printf '%s✓ %s%s\n' "$G" "$1" "$N"; }
warn(){ printf '%s! %s%s\n' "$Y" "$1" "$N"; }
err(){  printf '%s✗ %s%s\n' "$R" "$1" "$N"; }
die(){  err "$1"; exit 1; }
hr(){   printf '%s────────────────────────────────────────────────────────%s\n' "$C" "$N"; }

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
DIR="$(dirname "$SELF")"

# Resolve source paths whether invoked from repo root or SpoofMacintosh.app/Contents/Resources
if [ -d "$DIR/dist/SpoofMac.kext" ]; then
  KEXT_SRC="$DIR/dist/SpoofMac.kext"
elif [ -d "$DIR/SpoofMac.kext" ]; then
  KEXT_SRC="$DIR/SpoofMac.kext"
else
  KEXT_SRC=""
fi

if [ -x "$DIR/dist/spoofmac" ]; then
  CLI_SRC="$DIR/dist/spoofmac"
elif [ -x "$DIR/spoofmac" ]; then
  CLI_SRC="$DIR/spoofmac"
else
  CLI_SRC=""
fi

if [ -f "$DIR/scripts/spoofmac-boot.sh" ]; then
  BOOT_SRC="$DIR/scripts/spoofmac-boot.sh"
elif [ -f "$DIR/spoofmac-boot.sh" ]; then
  BOOT_SRC="$DIR/spoofmac-boot.sh"
else
  BOOT_SRC=""
fi

if [ -f "$DIR/scripts/com.spoofmacintosh.loader.plist" ]; then
  PLIST_SRC="$DIR/scripts/com.spoofmacintosh.loader.plist"
elif [ -f "$DIR/com.spoofmacintosh.loader.plist" ]; then
  PLIST_SRC="$DIR/com.spoofmacintosh.loader.plist"
else
  PLIST_SRC=""
fi

KEXT_DST="/Library/Extensions/SpoofMac.kext"
CLI_DST="/usr/local/bin/spoofmac"
BOOT_DST="/usr/local/bin/spoofmac-boot.sh"
PLIST_DST="/Library/LaunchDaemons/com.spoofmacintosh.loader.plist"
PREF_DST="/Library/Preferences/com.spoofmacintosh.plist"
KEXT_ID="com.spoofmacintosh.SpoofMac"
DAEMON="system/com.spoofmacintosh.loader"
LOG_PATH="/var/log/spoofmacintosh.log"

banner() {
  printf '%s\n' "$C"
  cat <<'EOF'
  ╔═════════════════════════════════════════════════════════════════════╗
  ║   SpoofMacintosh · Apple Silicon 全系列機型與地區動態偽裝解鎖工具     ║
  ║   Powered by NyphexAI, Developed by Hikaru(i@rua.moe)               ║
  ╚═════════════════════════════════════════════════════════════════════╝
EOF
  printf '%s' "$N"
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    info "需要系統管理員權限，正在透過 sudo 重新執行…"
    exec sudo "$SELF" "$@"
  fi
}

sip_fully_off() { csrutil status 2>/dev/null | grep -qi 'System Integrity Protection status: disabled'; }
sip_allows_kext() {
  local st
  st="$(csrutil status 2>/dev/null)"
  printf '%s\n' "$st" | grep -qi 'System Integrity Protection status: disabled' \
    || printf '%s\n' "$st" | grep -Eqi 'Kext Signing:[[:space:]]*disabled'
}

amfi_bypass_bootarg() {
  nvram boot-args 2>/dev/null \
    | grep -Eq '(^|[[:space:]])amfi_get_out_of_my_way(=[^[:space:]]*)?([[:space:]]|$)'
}

boot_vg() { diskutil info -plist / 2>/dev/null | plutil -extract APFSVolumeGroupID raw - 2>/dev/null; }

with_timeout() {
  local secs="$1"; shift
  if command -v perl >/dev/null 2>&1; then
    perl -e 'alarm shift; exec @ARGV or exit 127' "$secs" "$@"
  else
    "$@"
  fi
}

bputil_policy() {
  local vg
  vg="$(boot_vg)"
  if [ -n "$vg" ]; then
    with_timeout 20 bputil -d -v "$vg" </dev/null 2>/dev/null
  else
    with_timeout 20 bputil -d </dev/null 2>/dev/null
  fi
}

kext_policy_state() {
  local p
  p="$(bputil_policy | grep -E '3rd Party Kexts Status')"
  case "$p" in
    *Enabled*) echo enabled ;;
    *Disabled*) echo disabled ;;
    *) echo unknown ;;
  esac
}

kext_loaded() {
  kmutil showloaded --no-kernel-components 2>/dev/null | grep -qi "$KEXT_ID"
}

kext_fingerprint() {
  [ -f "$1/Contents/MacOS/SpoofMac" ] || return 0
  cat "$1/Contents/MacOS/SpoofMac" "$1/Contents/Info.plist" 2>/dev/null | shasum -a 256 | cut -c1-16
}

kext_gate_help() {
  cat <<'EOS'
  請依照以下正確順序在「恢復模式 (1TR)」開啟第三方 Kext 閘門（順序不可顛倒）：
    1. 關機 → 長按電源鍵進入「選項 (Options)」→ 頂部選單「實用工具 → 啟動安全性實用工具」
    2. 選擇目前系統磁碟 → 點選「安全策略… → 降低安全性」，並勾選：
       「允許使用者管理來自已識別開發者的核心擴展」→ 按「好」
    3. 【同一輪恢復模式中】立即打開「實用工具 → 終端機」，輸入：
       csrutil enable --without kext
       （步驟 2 會重設 SIP 設定，所以本指令必須在步驟 2 之後執行；若系統不接受則改用 csrutil disable）
    4. 輸入 reboot 重新開機；首次建立 AuxKC 可能需重開機兩次。之後再執行 sudo ./install.sh
EOS
}

explain_load_failure() {
  local out="$1" logs
  logs="$(log show --last 5m --style compact \
    --predicate 'process == "kernelmanagerd" OR process == "syspolicyd"' 2>/dev/null \
    | grep -iE 'SpoofMac|auxiliary extensions' | tail -20)"
  hr
  if [ "$(kext_policy_state)" = "disabled" ] || printf '%s\n%s\n' "$out" "$logs" | grep -qi 'auxiliary extensions not allowed'; then
    warn "Kext 載入被本地啟動安全性策略阻擋（未允許第三方 Kext）："
    kext_gate_help
  elif printf '%s\n' "$out" | grep -qi 'requires a reboot'; then
    warn "Kext 已獲批准，必須重新開機以完成 AuxKC 重建並載入。重開機後執行 sudo ./install.sh status 確認。"
  else
    warn "首次載入需要在「系統設定」手動批准一次："
    cat <<'EOS'
  1. 打開「系統設定 → 隱私與安全性」，捲動至最底部
  2. 點選「com.spoofmacintosh.SpoofMac 被阻擋」旁的 [允許 / Allow]
     （若只看到「啟用系統擴展… / Enable System Extensions…」，表示尚未在恢復模式開啟上述兩道閘門）
  3. 依提示重新開機（首次建構 AuxKC 可能需要重開機兩次）
EOS
  fi
  [ -n "$out" ] && printf '%s（kmutil 訊息: %s）%s\n' "$C" "$(printf '%s' "$out" | tail -1)" "$N"
}

preflight() {
  hr; info "執行環境預檢"
  [ "$(uname -m)" = "arm64" ] || die "SpoofMacintosh 僅支援 Apple Silicon (arm64)。"
  ok "Apple Silicon · macOS $(sw_vers -productVersion 2>/dev/null) ($(sw_vers -buildVersion 2>/dev/null))"

  [ -n "$KEXT_SRC" ] && [ -d "$KEXT_SRC" ] || die "找不到 SpoofMac.kext，請先執行 ./scripts/build.sh 建置。"
  [ -n "$CLI_SRC" ] && [ -x "$CLI_SRC" ] || die "找不到 spoofmac CLI，請先執行 ./scripts/build.sh 建置。"
  [ -n "$BOOT_SRC" ] && [ -f "$BOOT_SRC" ] || die "找不到 spoofmac-boot.sh。"
  [ -n "$PLIST_SRC" ] && [ -f "$PLIST_SRC" ] || die "找不到 com.spoofmacintosh.loader.plist。"
  ok "建置產物就緒"

  if ! sip_allows_kext; then
    err "目前 SIP 仍強制要求 Apple 簽章 Kext，ad-hoc 簽章的 SpoofMac.kext 無法載入。"
    hr
    kext_gate_help
    exit 1
  fi

  case "$(kext_policy_state)" in
    disabled)
      err "本地啟動策略未允許第三方核心擴展 (bputil: 3rd Party Kexts Status: Disabled)。"
      kext_gate_help
      exit 1 ;;
    enabled)
      ok "本地啟動策略已允許第三方核心擴展" ;;
    *)
      warn "無法透過 bputil 讀取啟動策略，繼續嘗試安裝。" ;;
  esac

  if sip_fully_off; then
    warn "SIP 目前為完全關閉狀態；可改用 csrutil enable --without kext 縮減安全豁免範圍。"
  else
    ok "SIP 保持啟用，僅豁免 Kext 簽章檢查"
  fi

  if amfi_bypass_bootarg; then
    warn "偵測到 boot-args 含有 amfi_get_out_of_my_way —— 此參數會破壞 PCC 私密雲端運算，正在自動移除…"
    local args new
    args="$(nvram boot-args 2>/dev/null | sed 's/^boot-args[[:space:]]*//')"
    new="$(printf '%s' "$args" \
      | sed -E 's/(^|[[:space:]])amfi_get_out_of_my_way(=[^[:space:]]*)?([[:space:]]|$)/ /g' \
      | xargs || true)"
    if [ -z "$new" ]; then
      nvram -d boot-args 2>/dev/null || true
    else
      nvram boot-args="$new" 2>/dev/null || true
    fi
    if amfi_bypass_bootarg; then
      die "無法自動清除 amfi_get_out_of_my_way，請於恢復模式終端機手動清理 boot-args。"
    fi
    AMFI_CHANGED=1
    ok "已移除 amfi_get_out_of_my_way（需重新開機後生效）"
  else
    ok "未發現破壞 PCC 的 AMFI 繞過參數"
  fi
}

strip_quarantine() {
  local f
  for f in "$KEXT_DST" "$CLI_DST" "$BOOT_DST" "$PLIST_DST"; do
    [ -e "$f" ] && xattr -dr com.apple.quarantine "$f" 2>/dev/null || true
  done
  ok "已清除 com.apple.quarantine 屬性"
}

do_install() {
  require_root "$@"
  banner
  preflight

  hr; info "安裝系統檔案"
  mkdir -p "$(dirname "$CLI_DST")" || die "無法建立 $(dirname "$CLI_DST")"

  local old_fp new_fp upgraded=0 out=""
  old_fp="$(kext_fingerprint "$KEXT_DST")"
  new_fp="$(kext_fingerprint "$KEXT_SRC")"
  if [ -n "$old_fp" ] && [ "$old_fp" = "$new_fp" ]; then
    ok "Kext 指紋相同 ($new_fp)，無須重新覆寫"
  else
    [ -n "$old_fp" ] && { upgraded=1; info "偵測到 Kext 更新 ($old_fp → $new_fp)"; }
    rm -rf "$KEXT_DST"
    cp -R "$KEXT_SRC" "$KEXT_DST" || die "複製 $KEXT_DST 失敗"
    chown -R 0:0 "$KEXT_DST"
    ok "已安裝 Kext → $KEXT_DST (root:wheel)"
  fi

  cp "$CLI_SRC" "$CLI_DST" && chown 0:0 "$CLI_DST" && chmod 755 "$CLI_DST" || die "安裝 $CLI_DST 失敗"
  ok "已安裝 CLI → $CLI_DST"

  cp "$BOOT_SRC" "$BOOT_DST" && chown 0:0 "$BOOT_DST" && chmod 755 "$BOOT_DST" || die "安裝 $BOOT_DST 失敗"
  cp "$PLIST_SRC" "$PLIST_DST" && chown 0:0 "$PLIST_DST" && chmod 644 "$PLIST_DST" || die "安裝 $PLIST_DST 失敗"
  strip_quarantine

  launchctl bootout "$DAEMON" >/dev/null 2>&1 || true
  if launchctl bootstrap system "$PLIST_DST" >/dev/null 2>&1 || launchctl print "$DAEMON" >/dev/null 2>&1; then
    ok "開機自動載入服務已註冊 ($DAEMON，日誌：$LOG_PATH)"
  else
    warn "LaunchDaemon 註冊異常，開機後請手動執行 sudo $BOOT_DST"
  fi

  hr; info "載入核心擴展與套用設定"
  if [ "$upgraded" = 1 ] && kext_loaded; then
    out="$(kmutil load -p "$KEXT_DST" 2>&1 || true)"
    warn "舊版 Kext 仍在核心中運行；請於「隱私與安全性」確認批准並重新開機兩次以啟用新版 Kext。"
    [ -n "$out" ] && printf '%s（kmutil: %s）%s\n' "$C" "$(printf '%s' "$out" | tail -1)" "$N"
    hr
    return 0
  fi

  if ! kext_loaded; then
    out="$(kmutil load -p "$KEXT_DST" 2>&1 || true)"
  fi

  if kext_loaded; then
    ok "SpoofMac.kext 已成功載入核心"
    if [ -f "$PREF_DST" ]; then
      "$CLI_DST" boot-load || warn "套用持久化設定檔時發生警告，請執行 sudo spoofmac status 檢查。"
    else
      "$CLI_DST" refresh || warn "資格重算回報異常，請執行 sudo spoofmac diagnose 檢視。"
    fi
    hr
    "$CLI_DST" status
    [ "$AMFI_CHANGED" = 1 ] && warn "剛已移除 AMFI 繞過參數，請重新開機後再測試 PCC 私密雲端運算。"
  else
    explain_load_failure "$out"
    exit 1
  fi
}

do_uninstall() {
  require_root "$@"
  banner; hr; info "卸載 SpoofMacintosh"
  launchctl bootout "$DAEMON" >/dev/null 2>&1 || true
  rm -f "$PLIST_DST" "$BOOT_DST" "$PREF_DST"
  if kext_loaded; then
    kmutil unload -b "$KEXT_ID" >/dev/null 2>&1 || true
  fi
  rm -rf "$KEXT_DST" "$CLI_DST"
  ok "已移除 Kext、CLI、設定檔與 LaunchDaemon"

  if [ -n "$CLI_SRC" ] && [ -x "$CLI_SRC" ]; then
    "$CLI_SRC" refresh >/dev/null 2>&1 || true
  fi
  hr
  warn "已觸發還原出廠硬體屬性與系統資格重算；如 Kext 無法熱卸載，重新開機後即完全恢復原廠狀態。"
  hr
}

resolve_cli_for_passthru() {
  if [ -x "$CLI_DST" ]; then
    echo "$CLI_DST"
  elif [ -n "$CLI_SRC" ] && [ -x "$CLI_SRC" ]; then
    echo "$CLI_SRC"
  else
    die "找不到 spoofmac 執行檔，請先執行 ./scripts/build.sh。"
  fi
}

case "${1:-install}" in
  install)
    do_install "$@"
    ;;
  uninstall|remove)
    do_uninstall "$@"
    ;;
  status|diagnose|list-models|list-regions)
    exec "$(resolve_cli_for_passthru)" "$@"
    ;;
  apply|reset|refresh|boot-load)
    require_root "$@"
    exec "$(resolve_cli_for_passthru)" "$@"
    ;;
  *)
    echo "用法: $0 [install|status|apply|reset|refresh|diagnose|list-models|list-regions|uninstall]"
    exit 1
    ;;
esac
