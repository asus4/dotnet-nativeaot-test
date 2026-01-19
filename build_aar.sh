#!/bin/bash
set -e

PROJECT="NativeAotLib/NativeAotLib.csproj"
LIBRARY_NAME="NativeAotLib"
BASE_PATH="NativeAotLib/bin/Release/net10.0"
PACKAGE_NAME="com.example.nativeaotlib"
JNI_SOURCE_DIR="MyNativeAOTAndroid/app/src/main/cpp"

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

# Function to get NDK target for architecture
get_ndk_target() {
  case "$1" in
    "arm64-v8a") echo "aarch64-linux-android" ;;
    "armeabi-v7a") echo "armv7a-linux-androideabi" ;;
    "x86_64") echo "x86_64-linux-android" ;;
    "x86") echo "i686-linux-android" ;;
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

# Create AAR structure (AAR uses "jni/" not "jniLibs/")
mkdir -p jni

# Build JNI wrapper and copy .so files for each architecture
MIN_SDK_VERSION=29

for rid in "${RIDS[@]}"; do
  abi=$(get_abi_for_rid "$rid")
  ndk_target=$(get_ndk_target "$abi")
  mkdir -p "jni/$abi"

  # Copy the NativeAOT .so file
  so_path="../$BASE_PATH/$rid/publish/$LIBRARY_NAME.so"
  if [ -f "$so_path" ]; then
    cp "$so_path" "jni/$abi/lib$LIBRARY_NAME.so"
    echo "[OK] Copied $rid -> jni/$abi/lib$LIBRARY_NAME.so"
  else
    echo "[WARN] $so_path not found"
    continue
  fi

  # Build JNI wrapper for this architecture
  echo "Building JNI wrapper for $abi..."

  # Create a temporary build directory for this architecture
  mkdir -p "jni_build/$abi"

  # Compile the JNI wrapper using NDK directly
  # The JNI wrapper uses dlopen/dlsym to load NativeAotLib at runtime,
  # avoiding Android's linker namespace issues with DT_NEEDED dependencies.
  CC="${ndk_target}${MIN_SDK_VERSION}-clang"

  $CC -shared -fPIC \
    -I"$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include" \
    -o "jni/$abi/libnativeaot_jni.so" \
    "../$JNI_SOURCE_DIR/nativeaot_jni.c" \
    -llog -ldl

  echo "[OK] Built JNI wrapper for $abi"
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
jar cf "$LIBRARY_NAME.aar" AndroidManifest.xml classes.jar jni

echo "[OK] Created: aar_build/$LIBRARY_NAME.aar"
echo "AAR Contents:"
jar tf "$LIBRARY_NAME.aar"

# Copy AAR to Android project
ANDROID_LIBS_DIR="../MyNativeAOTAndroid/app/libs"
mkdir -p "$ANDROID_LIBS_DIR"
cp "$LIBRARY_NAME.aar" "$ANDROID_LIBS_DIR/"
echo "[OK] Copied to: MyNativeAOTAndroid/app/libs/$LIBRARY_NAME.aar"
