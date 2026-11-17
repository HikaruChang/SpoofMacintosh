# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0

.PHONY: all build test clean kext-check release bump-version

all: build

build:
	@./scripts/build.sh

test:
	@swift test

kext-check: build
	@file dist/SpoofMac.kext/Contents/MacOS/SpoofMac
	@kmutil libraries --arch arm64e -p dist/SpoofMac.kext
	@codesign --verify --verbose=2 dist/SpoofMac.kext
	@codesign --verify --deep --strict --verbose=2 dist/SpoofMacintosh.app

release:
	@./scripts/package-release.sh

bump-version:
	@if [ -z "$(V)" ]; then echo "Usage: make bump-version V=1.0.1" >&2; exit 1; fi
	@./scripts/bump-version.sh "$(V)"

clean:
	@rm -rf .build dist release SpoofMac.kext
