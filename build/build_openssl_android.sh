#!/bin/bash
set -e

# Cross-builds OpenSSL (libssl.so + libcrypto.so) for Android using the NDK and
# drops the .so files next to libNativeAotLib.so in the Android project's jniLibs.
#
# Why: the linux-bionic NativeAOT runtime resolves TLS through OpenSSL, which
# Android does not ship. The managed crypto shim dlopen()s the *unversioned*
# names "libssl.so" / "libcrypto.so" on Android, and OpenSSL's android-* targets
# produce exactly those (no ".so.3" suffix, unversioned SONAME), so they can be
# packaged in jniLibs and loaded from the app's native library namespace.
#
# Run from the repo root regardless of where the script is invoked.
cd "$(dirname "$0")/.."

OPENSSL_BRANCH="openssl-3.0"
SRC_DIR="build/openssl-src"
JNILIBS_DIR="examples/AndroidNativeAotExample/app/src/main/jniLibs"
ANDROID_API=26 # must match app/build.gradle.kts minSdk

# Builds both ABIs the Android project targets by default. Pass ABIs as
# arguments to override, e.g. `./build/build_openssl_android.sh arm64-v8a`.
ABIS=("$@")
if [ ${#ABIS[@]} -eq 0 ]; then
  ABIS=("arm64-v8a" "x86_64")
fi

if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "[ERROR] ANDROID_NDK_ROOT is not set."
  exit 1
fi
export ANDROID_NDK_ROOT
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

get_openssl_target() {
  case "$1" in
    "arm64-v8a") echo "android-arm64" ;;
    "x86_64")    echo "android-x86_64" ;;
    *) echo "unknown" ;;
  esac
}

# Shallow-clone the OpenSSL maintenance branch once; reused on subsequent runs.
if [ ! -d "$SRC_DIR" ]; then
  echo "Cloning OpenSSL ($OPENSSL_BRANCH)..."
  git clone --depth 1 -b "$OPENSSL_BRANCH" https://github.com/openssl/openssl "$SRC_DIR"
fi
SRC_ABS="$(cd "$SRC_DIR" && pwd)"

for abi in "${ABIS[@]}"; do
  target=$(get_openssl_target "$abi")
  if [ "$target" = "unknown" ]; then
    echo "[WARN] No OpenSSL target mapping for ABI '$abi'; skipping."
    continue
  fi

  build_dir="build/openssl-build/$abi"
  echo "Building OpenSSL for $abi ($target)..."
  rm -rf "$build_dir"
  mkdir -p "$build_dir"
  (
    cd "$build_dir"
    # no-tests keeps the configure step lean; the build_libs target below builds
    # only libssl.so + libcrypto.so (no apps), which is all we ship.
    "$SRC_ABS/Configure" "$target" -D__ANDROID_API__="$ANDROID_API" \
      no-tests shared
    make -j"$(sysctl -n hw.ncpu)" build_libs
  )

  out_dir="$JNILIBS_DIR/$abi"
  mkdir -p "$out_dir"
  for lib in libssl.so libcrypto.so; do
    cp "$build_dir/$lib" "$out_dir/$lib"
    echo "[OK] $build_dir/$lib -> $out_dir/$lib"
  done
done

echo "[DONE] OpenSSL .so files placed in $JNILIBS_DIR/<abi>/"
