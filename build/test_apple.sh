#!/bin/bash
set -e

# Runs the macOS interop tests for the Apple example.
cd "$(dirname "$0")/.."

PROJECT="examples/AppleNativeAotExample/AppleNativeAotExample.xcodeproj"
SCHEME="AppleNativeAotExample"

xcodebuild test -project "$PROJECT" -scheme "$SCHEME" -destination 'platform=macOS'
