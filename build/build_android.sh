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
    "android-arm64") echo "arm64-v8a" ;;
    "android-x64")   echo "x86_64" ;;
    *) echo "unknown" ;;
  esac
}

# arm/x86 cross-compiles from Apple Silicon hosts are not supported yet
RIDS=("android-arm64" "android-x64")

for rid in "${RIDS[@]}"; do
  echo "Publishing for $rid..."
  dotnet publish -r "$rid" "$PROJECT" -c Release
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

echo "[DONE] Native AOT .so files placed in $JNILIBS_DIR/<abi>/"
