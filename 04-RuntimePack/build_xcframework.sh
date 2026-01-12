#!/bin/bash
set -e

PROJECT="MyNativeAOTLibrary/MyNativeAOTLibrary.csproj"
FRAMEWORK_NAME="MyNativeAOTLibrary"
BASE_PATH="MyNativeAOTLibrary/bin/Release/net10.0"

# Publish all RIDs
RIDS=("osx-x64" "osx-arm64" "ios-arm64" "iossimulator-arm64" "iossimulator-x64")
for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid..."
  dotnet publish -r $rid $PROJECT -c Release
done

# Clean up the working dir
rm -rf xcframework_build && mkdir xcframework_build && cd xcframework_build
mkdir -p macos ios iossimulator

# Build fat binaries
lipo -create \
  ../$BASE_PATH/osx-x64/publish/$FRAMEWORK_NAME.dylib \
  ../$BASE_PATH/osx-arm64/publish/$FRAMEWORK_NAME.dylib \
  -output $FRAMEWORK_NAME-macos.dylib

lipo -create \
  ../$BASE_PATH/iossimulator-x64/publish/$FRAMEWORK_NAME.dylib \
  ../$BASE_PATH/iossimulator-arm64/publish/$FRAMEWORK_NAME.dylib \
  -output $FRAMEWORK_NAME-iossimulator.dylib

# Make framework directories and copy binaries
mkdir -p macos/$FRAMEWORK_NAME.framework
mkdir -p ios/$FRAMEWORK_NAME.framework
mkdir -p iossimulator/$FRAMEWORK_NAME.framework

cp $FRAMEWORK_NAME-macos.dylib macos/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME
cp ../$BASE_PATH/ios-arm64/publish/$FRAMEWORK_NAME.dylib ios/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME
cp $FRAMEWORK_NAME-iossimulator.dylib iossimulator/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME

# install_name_tool
for platform in macos ios iossimulator; do
  install_name_tool -id @rpath/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME \
    $platform/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME
done

# 7. Info.plist追加
for platform in macos ios iossimulator; do
cat > $platform/$FRAMEWORK_NAME.framework/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$FRAMEWORK_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
</dict>
</plist>
EOF
done

# Create XCFramework
xcodebuild -create-xcframework \
  -framework macos/$FRAMEWORK_NAME.framework \
  -framework ios/$FRAMEWORK_NAME.framework \
  -framework iossimulator/$FRAMEWORK_NAME.framework \
  -output $FRAMEWORK_NAME.xcframework

echo "✅ Created: xcframework_build/$FRAMEWORK_NAME.xcframework"
