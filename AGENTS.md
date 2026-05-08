# dotnet-nativeaot-test

A minimal sample that builds a C# library with .NET Native AOT as a native library for iOS / macOS / Android, then calls it from Swift / Kotlin. The goal is to validate a setup that does not go through Mono.

Work log (in Japanese): <https://zenn.dev/asus4/scraps/690d551fc93a85>

## Layout

- `NativeAotLib/` — Shared net10.0 C# library exposing a C ABI via `UnmanagedCallersOnly`.
- `include/aot_nativemethods.h` — Canonical C declarations for the AOT exports. Imported by both the Apple bridging header and the Android JNI shim.
- `MyNativeAOTApple/` — Xcode project. Consumes the `NativeAotLib.xcframework` produced by `build_xcframework.sh` through a bridging header.
- `MyNativeAOTAndroid/` — Android Studio project. Consumes the prebuilt `.so` from `app/src/main/jniLibs/<abi>/` and a thin JNI shim built by Gradle's CMake (`app/src/main/cpp/`). Kotlin calls into the native code via direct JNI with `@CriticalNative` for primitive methods (no JNA / reflection).
- `build_xcframework.sh` — Runs `dotnet publish` for each osx / ios / iossimulator RID, then assembles the xcframework with `lipo` and `xcodebuild -create-xcframework`.
- `build_android.sh` — Publishes a `.so` for each Android ABI using the NDK toolchain and copies them into `MyNativeAOTAndroid/app/src/main/jniLibs/<abi>/`.

## Build

```bash
./build_xcframework.sh   # → MyNativeAOTApple/MyNativeAOTApple/NativeAotLib.xcframework
./build_android.sh       # → MyNativeAOTAndroid/app/src/main/jniLibs/{arm64-v8a,x86_64}/libNativeAotLib.so
```

Then open the corresponding project in Xcode / Android Studio and run the app.

## Notes

- Android currently builds only `android-arm64` and `android-x64`. `android-arm` and `android-x86` are excluded because they cannot be cross-compiled on Apple Silicon hosts.
- `ANDROID_NDK_ROOT` in `build_android.sh` is hard-coded to a local path; adjust if your environment differs.
- Android bridge uses direct JNI: a small `aot_jni.c` shim registers native methods via `RegisterNatives` in `JNI_OnLoad`. The primitive-only `aotsample_add` is bound directly to the AOT export with no wrapper thanks to `@CriticalNative` (calling convention drops `JNIEnv*` / `jclass`). The two string methods use thin wrappers for `GetStringUTFChars` / `NewStringUTF` + `free`. `minSdk = 34` so `dalvik.annotation.optimization.CriticalNative` is part of the public SDK and no annotation stub is needed.
