# dotnet-nativeaot-test

A minimal sample that builds a C# library with .NET Native AOT as a native library for iOS / macOS / Android, then calls it from Swift / Kotlin. The goal is to validate a setup that does not go through Mono.

## Layout

- `src/NativeAotLib/` — Shared .NET library exposing a C ABI via `UnmanagedCallersOnly`.
- `src/NativeAotLib/include/aot_nativemethods.h` — Canonical C declarations for the AOT exports. Ships with the library that produces them; imported by both the Apple bridging header and the Android JNI shim.
- `examples/MyNativeAOTApple/` — Xcode project. Consumes the `NativeAotLib.xcframework` produced by `build/build_apple.sh` through a bridging header.
- `examples/MyNativeAOTAndroid/` — Android Studio project. Consumes the prebuilt `.so` from `app/src/main/jniLibs/<abi>/` and a thin JNI shim built by Gradle's CMake (`app/src/main/cpp/`). Kotlin calls into the native code via direct JNI with `@CriticalNative` for primitive methods (no JNA / reflection).
- `build/build_apple.sh` — Runs `dotnet publish` for each osx / ios / iossimulator RID, then assembles the xcframework with `lipo` and `xcodebuild -create-xcframework`.
- `build/build_android.sh` — Publishes a `.so` for each Android ABI using the NDK toolchain and copies them into `examples/MyNativeAOTAndroid/app/src/main/jniLibs/<abi>/`.
- `Directory.Build.props` / `global.json` — Shared MSBuild properties (`ImplicitUsings`, `Nullable`) and the pinned .NET SDK version.

## Build

The scripts anchor themselves to the repo root, so they can be run from anywhere.

```bash
./build/build_apple.sh     # → examples/MyNativeAOTApple/MyNativeAOTApple/NativeAotLib.xcframework
./build/build_android.sh   # → examples/MyNativeAOTAndroid/app/src/main/jniLibs/{arm64-v8a,x86_64}/libNativeAotLib.so
```

Then open the corresponding project in Xcode / Android Studio and run the app.

## Notes

- Android currently builds only `android-arm64` and `android-x64`. `android-arm` and `android-x86` are excluded because they cannot be cross-compiled on Apple Silicon hosts.
- `ANDROID_NDK_ROOT` in `build/build_android.sh` is hard-coded to a local path; adjust if your environment differs.
- Android bridge uses direct JNI: a small `aot_jni.c` shim registers native methods via `RegisterNatives` in `JNI_OnLoad`. The primitive-only `aotsample_add` is bound directly to the AOT export with no wrapper thanks to `@CriticalNative` (calling convention drops `JNIEnv*` / `jclass`). The two string methods use thin wrappers for `GetStringUTFChars` / `NewStringUTF` + `free`. `minSdk = 34` so `dalvik.annotation.optimization.CriticalNative` is part of the public SDK and no annotation stub is needed.
- The shim resolves AOT exports via `dlopen("libNativeAotLib.so")` + `dlsym` in `JNI_OnLoad`, not link-time linking. The .NET-published `.so` has no `SONAME`, so linking against it bakes the absolute build-host path into `DT_NEEDED` and the loader fails on the device with `dlopen failed: library "/.../libNativeAotLib.so" not found`. `NativeAot.kt` calls `System.loadLibrary("NativeAotLib")` before `aot_jni`, so the subsequent `dlopen` from the shim just bumps the refcount.
- Both `.so` files ship with 16 KB ELF alignment for Android 15+ devices that use a 16 KB page size. The AOT-built `libNativeAotLib.so` is 16 KB-aligned by default in .NET 10; the CMake-built `libaot_jni.so` shim adds `-Wl,-z,max-page-size=16384` explicitly in `examples/MyNativeAOTAndroid/app/src/main/cpp/CMakeLists.txt`.
