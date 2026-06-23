#!/bin/bash
set -e

# Compiles the "NativeFib" Fibonacci C source into a per-RID static
# library (libnativefib.a) for every RID.
#
# Run this ONCE before 
# ./build/build_apple.sh
# ./build/build_android.sh

# Run from the repo root regardless of where the script is invoked.
cd "$(dirname "$0")/.."

PKG_DIR="src/NativeFib"
SRC="$PKG_DIR/native/fib.c"
LIB_NAME="nativefib" # produces libnativefib.a

# ---- Apple slices (clang via xcrun) ----
# rid | sdk | target-triple
APPLE_TARGETS=(
  "osx-arm64|macosx|arm64-apple-macos11.0"
  "osx-x64|macosx|x86_64-apple-macos11.0"
  "ios-arm64|iphoneos|arm64-apple-ios12.0"
  "iossimulator-arm64|iphonesimulator|arm64-apple-ios12.0-simulator"
  "iossimulator-x64|iphonesimulator|x86_64-apple-ios12.0-simulator"
)

build_apple() {
  for entry in "${APPLE_TARGETS[@]}"; do
    IFS='|' read -r rid sdk triple <<< "$entry"
    local sysroot
    sysroot="$(xcrun --sdk "$sdk" --show-sdk-path)"
    local out_dir="$PKG_DIR/runtimes/$rid/native"
    local obj="$out_dir/fib.o"
    mkdir -p "$out_dir"
    clang -c -Os -fPIC -target "$triple" -isysroot "$sysroot" "$SRC" -o "$obj"
    # libtool is Apple's recommended static-archiver (writes a proper TOC for ld64).
    xcrun --sdk "$sdk" libtool -static -o "$out_dir/lib$LIB_NAME.a" "$obj"
    rm -f "$obj"
    echo "[OK] $rid -> $out_dir/lib$LIB_NAME.a"
  done
}

# ---- Android slices (NDK clang) ----
build_android() {
  if [ -z "$ANDROID_NDK_ROOT" ]; then
    echo "[WARN] ANDROID_NDK_ROOT not set — skipping Android slices."
    return
  fi
  local ndk_bin="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin"
  # rid | ndk-clang wrapper (API 26 matches the OpenSSL build)
  local entries=(
    "linux-bionic-arm64|aarch64-linux-android26-clang"
    "linux-bionic-x64|x86_64-linux-android26-clang"
  )
  for entry in "${entries[@]}"; do
    IFS='|' read -r rid cc <<< "$entry"
    local out_dir="$PKG_DIR/runtimes/$rid/native"
    local obj="$out_dir/fib.o"
    mkdir -p "$out_dir"
    "$ndk_bin/$cc" -c -Os -fPIC "$SRC" -o "$obj"
    "$ndk_bin/llvm-ar" rcs "$out_dir/lib$LIB_NAME.a" "$obj"
    rm -f "$obj"
    echo "[OK] $rid -> $out_dir/lib$LIB_NAME.a"
  done
}

build_apple
build_android

echo "[DONE] Built NativeFib static libs into $PKG_DIR/runtimes"
