#!/bin/bash
set -e

# Run from the repo root regardless of where the script is invoked.
cd "$(dirname "$0")/.."

PROJECT="src/NativeAotLib/NativeAotLib.csproj"
LIBRARY_NAME="NativeAotLib"
BASE_PATH="src/NativeAotLib/bin/Release/net10.0"
JNILIBS_DIR="examples/AndroidNativeAotExample/app/src/main/jniLibs"

# Expects ANDROID_NDK_ROOT to be set in your environment (e.g. in ~/.zshrc).
if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "[ERROR] ANDROID_NDK_ROOT is not set."
  exit 1
fi
export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

get_abi_for_rid() {
  case "$1" in
    "linux-bionic-arm64") echo "arm64-v8a" ;;
    "linux-bionic-x64")   echo "x86_64" ;;
    *) echo "unknown" ;;
  esac
}

# We use the linux-bionic-* RIDs rather than android-* so that HTTPS works.
RIDS=("linux-bionic-arm64" "linux-bionic-x64")

for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid..."
  # DisableUnsupportedError: linux-bionic is an unsupported-by-default RID for
  # cross-OS publishing, but the NDK toolchain produces a valid Android .so.
  dotnet publish -r "$rid" "$PROJECT" -c Release -p:DisableUnsupportedError=true
done

for rid in "${RIDS[@]}"; do
  abi=$(get_abi_for_rid "$rid")
  out_dir="$JNILIBS_DIR/$abi"
  mkdir -p "$out_dir"
  src="$BASE_PATH/$rid/publish/$LIBRARY_NAME.so"
  dst="$out_dir/lib$LIBRARY_NAME.so"
  if [ -f "$src" ]; then
    cp "$src" "$dst"
    echo "[OK] $src -> $dst"
  else
    echo "[WARN] $src not found"
    exit 1
  fi
done

# The bionic runtime dlopen()s libssl.so/libcrypto.so at runtime for HTTPS.
# They are not produced here; remind the user to build them once.
for rid in "${RIDS[@]}"; do
  abi=$(get_abi_for_rid "$rid")
  if [ ! -f "$JNILIBS_DIR/$abi/libssl.so" ]; then
    echo "[WARN] $JNILIBS_DIR/$abi/libssl.so missing — HTTPS will fail at runtime."
    echo "       Run: ./build/build_openssl_android.sh $abi"
  fi
done

echo "[DONE] Native AOT .so files placed in $JNILIBS_DIR/<abi>/"
