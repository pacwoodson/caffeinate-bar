#!/bin/bash
# Build CaffeinateBar.app and install it in ~/Applications.
set -euo pipefail
cd "$(dirname "$0")"
APP=build/CaffeinateBar.app
rm -rf build && mkdir -p "$APP/Contents/MacOS"
swiftc -O -target "$(uname -m)-apple-macos13.0" -o "$APP/Contents/MacOS/CaffeinateBar" main.swift
mkdir -p "$APP/Contents/Resources"
swift make-icon.swift build/AppIcon.iconset
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>CaffeinateBar</string>
  <key>CFBundleExecutable</key><string>CaffeinateBar</string>
  <key>CFBundleIdentifier</key><string>eu.sustainsoft.caffeinatebar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
mkdir -p ~/Applications
rm -rf ~/Applications/CaffeinateBar.app
cp -R "$APP" ~/Applications/
echo "Installed: ~/Applications/CaffeinateBar.app"
