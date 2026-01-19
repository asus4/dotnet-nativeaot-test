#!/bin/bash
set -e

PROJECT="NativeAotLib/NativeAotLib.csproj"
FRAMEWORK_NAME="NativeAotLib"
BASE_PATH="NativeAotLib/bin/Release/net10.0"
BUNDLE_ID="com.example.$FRAMEWORK_NAME"

# Make Info.plist in the specified path
create_info_plist() {
  local output_path="$1"
  cat > "$output_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
</dict>
</plist>
EOF
}

# Create versioned framework (for macOS)
create_versioned_framework() {
  local platform_dir="$1"
  local binary_path="$2"
  local fw_dir="$platform_dir/$FRAMEWORK_NAME.framework"
  
  mkdir -p "$fw_dir/Versions/A/Resources"
  ln -sfh A "$fw_dir/Versions/Current"
  ln -sfh Versions/Current/$FRAMEWORK_NAME "$fw_dir/$FRAMEWORK_NAME"
  ln -sfh Versions/Current/Resources "$fw_dir/Resources"
  
  cp "$binary_path" "$fw_dir/Versions/A/$FRAMEWORK_NAME"
  install_name_tool -id @rpath/$FRAMEWORK_NAME.framework/Versions/A/$FRAMEWORK_NAME \
  "$fw_dir/Versions/A/$FRAMEWORK_NAME"
  create_info_plist "$fw_dir/Versions/A/Resources/Info.plist"
}

# Create shallow framework (for iOS and iOS Simulator)
create_shallow_framework() {
  local platform_dir="$1"
  local binary_path="$2"
  local fw_dir="$platform_dir/$FRAMEWORK_NAME.framework"
  
  mkdir -p "$fw_dir"
  cp "$binary_path" "$fw_dir/$FRAMEWORK_NAME"
  install_name_tool -id @rpath/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME \
    "$fw_dir/$FRAMEWORK_NAME"
  create_info_plist "$fw_dir/Info.plist"
}

# Publish for all RIDs
RIDS=("osx-x64" "osx-arm64" "ios-arm64" "iossimulator-arm64" "iossimulator-x64")
for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid..."
  dotnet publish -r $rid $PROJECT -c Release
done

# Cleanup Working directory
rm -rf xcframework_build && mkdir xcframework_build && cd xcframework_build
mkdir -p macos ios iossimulator

# Create fat binary
lipo -create \
  ../$BASE_PATH/osx-x64/publish/$FRAMEWORK_NAME.dylib \
  ../$BASE_PATH/osx-arm64/publish/$FRAMEWORK_NAME.dylib \
  -output $FRAMEWORK_NAME-macos.dylib

lipo -create \
  ../$BASE_PATH/iossimulator-x64/publish/$FRAMEWORK_NAME.dylib \
  ../$BASE_PATH/iossimulator-arm64/publish/$FRAMEWORK_NAME.dylib \
  -output $FRAMEWORK_NAME-iossimulator.dylib

# Create frameworks
create_versioned_framework "macos" "$FRAMEWORK_NAME-macos.dylib"
create_shallow_framework "ios" "../$BASE_PATH/ios-arm64/publish/$FRAMEWORK_NAME.dylib"
create_shallow_framework "iossimulator" "$FRAMEWORK_NAME-iossimulator.dylib"

# Create XCFramework
xcodebuild -create-xcframework \
  -framework macos/$FRAMEWORK_NAME.framework \
  -framework ios/$FRAMEWORK_NAME.framework \
  -framework iossimulator/$FRAMEWORK_NAME.framework \
  -output $FRAMEWORK_NAME.xcframework

echo "✅ Created: xcframework_build/$FRAMEWORK_NAME.xcframework"

# Move XCFramework to MyNativeAOTApple project
rm -rf ../MyNativeAOTApple/MyNativeAOTApple/$FRAMEWORK_NAME.xcframework
mv $FRAMEWORK_NAME.xcframework ../MyNativeAOTApple/MyNativeAOTApple
