#!/bin/bash
set -e

echo "🔨 Building TranslatorGhost Release..."
swift build -c release

echo "📦 Packaging macOS Application Bundle..."
APP_DIR="/Applications/TranslatorGhost.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy binary
cp .build/release/TranslatorGhost "$APP_DIR/Contents/MacOS/TranslatorGhost"

# Copy Info.plist
cp Info.plist "$APP_DIR/Contents/Info.plist"

echo "🔐 Setting executive permission and local signing..."
chmod +x "$APP_DIR/Contents/MacOS/TranslatorGhost"
codesign --force --deep --sign - "$APP_DIR"

echo "✅ Successfully built and deployed to: $APP_DIR"
