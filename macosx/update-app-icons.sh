#!/bin/bash
# Regenerates the prebuilt app icon files from macosx/Paperboat.icon (Icon Composer).
# Run it after editing the icon, with Xcode 27+: older actool versions leave out the macOS 27 /
# iOS 27 icon effects. The build only copies the committed results, so it works with any Xcode.
#   macosx/Assets.car       Liquid Glass icon for macOS 26+
#   macosx/Paperboat.icns   full-size flat icon for older macOS, extracted from that catalog
#   ios/Assets.car          Liquid Glass icon for iOS 26+, with flat renditions for older iOS
set -euo pipefail
cd "$(dirname "$0")/.."
XCODE_MAJOR=$(xcodebuild -version | awk 'NR==1{split($2, v, "."); print v[1]}')
[ "$XCODE_MAJOR" -ge 27 ] || { echo "Xcode 27+ needed for the 27 icon effects (found Xcode $XCODE_MAJOR)" >&2; exit 1; }
ICON="$PWD/macosx/Paperboat.icon"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

compile() { # out dir, actool platform args...
    local out=$1
    shift
    mkdir -p "$out"
    xcrun actool "$ICON" --compile "$out" --app-icon Paperboat --output-partial-info-plist "$out/partial.plist" \
        "$@" --errors --warnings >/dev/null
    [ -f "$out/Assets.car" ] || { echo "actool produced no Assets.car" >&2; exit 1; }
}

# Minimums match LSMinimumSystemVersion (Info.plist) and the iOS DEPLOYMENT_TARGET.
compile "$TMP/mac" --platform macosx --target-device mac --minimum-deployment-target 12.0
cp "$TMP/mac/Assets.car" macosx/Assets.car
iconutil -c icns macosx/Assets.car Paperboat -o macosx/Paperboat.icns

compile "$TMP/ios" --platform iphoneos --target-device iphone --target-device ipad --minimum-deployment-target 16.3
# actool also writes loose PNGs for iOS 10 and older; Paperboat needs iOS 16.3, so they are not kept.
cp "$TMP/ios/Assets.car" ios/Assets.car

echo "Updated macosx/Assets.car, macosx/Paperboat.icns and ios/Assets.car"
