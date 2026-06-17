# dotnet-nativeaot-test

A minimal example that builds an .NET code as a native library for iOS / macOS / Android, then calls it from native Swift / Kotlin. The goal is to test a minimal setup for C# -> native interop workflow.

## Layout

- `src/NativeAotLib/` — Shared .NET library exposing a C ABI via `UnmanagedCallersOnly`.
- `src/NativeAotLib/include/aot_nativemethods.h` — Canonical C declarations for the AOT exports. Ships with the library that produces them; imported by both the Apple bridging header and the Android JNI shim.
- `examples/MyNativeAOTApple/` — Xcode project. Consumes the `NativeAotLib.xcframework` produced by `build/build_apple.sh` through a bridging header.
- `examples/MyNativeAOTAndroid/` — Android Studio project. Consumes the prebuilt `.so` from `app/src/main/jniLibs/<abi>/` and a thin JNI shim built by Gradle's CMake (`app/src/main/cpp/`). Kotlin calls into the native code via direct JNI with `@CriticalNative` for primitive methods (no JNA / reflection).
- `build/build_apple.sh` — Runs `dotnet publish` for each osx / ios / iossimulator RID, then assembles the xcframework with `lipo` and `xcodebuild -create-xcframework`.
- `build/build_android.sh` — Publishes a `.so` for each Android ABI using the NDK toolchain and copies them into `examples/MyNativeAOTAndroid/app/src/main/jniLibs/<abi>/`.
- `Directory.Build.props` / `global.json` — Shared MSBuild properties (`ImplicitUsings`, `Nullable`) and the pinned .NET SDK version.

## Build

```sh

# Build xcframework for macOS / iOS and move it to the Xcode project
./build/build_apple.sh

# Build .so for Android and move it to the Android Studio project
./build/build_android.shlibNativeAotLib.so
```

Then open the corresponding project in Xcode / Android Studio and run the app.
