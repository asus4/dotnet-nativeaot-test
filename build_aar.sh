#!/bin/bash
set -e

PROJECT="NativeAotLib.Android/NativeAotLib.Android.csproj"
LIBRARY_NAME="NativeAotLib"
BASE_PATH="NativeAotLib.Android/bin/Release/net10.0"
PACKAGE_NAME="com.example.nativeaotlib"

# Set your Android NDK path
export ANDROID_NDK_ROOT="$HOME/Library/Android/sdk/ndk/29.0.14206865"
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

# Function to convert RID to Android ABI
get_abi_for_rid() {
  case "$1" in
    "android-arm64") echo "arm64-v8a" ;;
    "android-arm") echo "armeabi-v7a" ;;
    "android-x64") echo "x86_64" ;;
    "android-x86") echo "x86" ;;
    *) echo "unknown" ;;
  esac
}

# Publish for all Android RIDs
# RIDS=("android-arm64" "android-arm" "android-x64" "android-x86")
# arm/x64 cross-compiles are not yet supported on Apple Silicon hosts
RIDS=("android-arm64" "android-x64")
for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid..."
  dotnet publish -r $rid $PROJECT -c Release
done

# Cleanup and create working directory
rm -rf aar_build && mkdir -p aar_build
cd aar_build

# Create AAR structure
mkdir -p jniLibs

# Copy .so files to the correct jniLibs directories
for rid in "${RIDS[@]}"; do
  abi=$(get_abi_for_rid "$rid")
  mkdir -p "jniLibs/$abi"

  # Find and copy the .so file
  so_path="../$BASE_PATH/$rid/publish/$LIBRARY_NAME.so"
  if [ -f "$so_path" ]; then
    cp "$so_path" "jniLibs/$abi/$LIBRARY_NAME.so"
    echo "✅ Copied $rid → jniLibs/$abi/$LIBRARY_NAME.so"
  else
    echo "⚠️  Warning: $so_path not found"
  fi
done

# Create AndroidManifest.xml
cat > AndroidManifest.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$PACKAGE_NAME"
    android:versionCode="1"
    android:versionName="1.0">
    <uses-sdk android:minSdkVersion="21" />
</manifest>
EOF

# Create empty classes.jar (AAR requires this even if empty)
mkdir -p temp_classes
echo "Manifest-Version: 1.0" > temp_classes/MANIFEST.MF
jar cfm classes.jar temp_classes/MANIFEST.MF -C temp_classes .
rm -rf temp_classes

# Create AAR (it's just a zip file with specific structure)
jar cf "$LIBRARY_NAME.aar" AndroidManifest.xml classes.jar jniLibs

echo ""
echo "✅ Created: aar_build/$LIBRARY_NAME.aar"
echo ""
echo "AAR Contents:"
jar tf "$LIBRARY_NAME.aar"