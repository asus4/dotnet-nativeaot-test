# dotnet-nativeaot-test

A minimal sample that builds a C# library with .NET Native AOT as a native library for iOS / macOS / Android, then calls it from Swift / Kotlin. The goal is to validate a setup that does not go through Mono.

Work log (in Japanese): <https://zenn.dev/asus4/scraps/690d551fc93a85>

## Layout

- `NativeAotLib/` — Shared net10.0 C# library exposing a C ABI via `UnmanagedCallersOnly`.
- `MyNativeAOTApple/` — Xcode project. Consumes the `NativeAotLib.xcframework` produced by `build_xcframework.sh` through a bridging header.
- `MyNativeAOTAndroid/` — Android Studio project. Consumes the AAR produced by `build_aar.sh` from `app/libs/`. Kotlin calls into the native code via JNA.
- `build_xcframework.sh` — Runs `dotnet publish` for each osx / ios / iossimulator RID, then assembles the xcframework with `lipo` and `xcodebuild -create-xcframework`.
- `build_aar.sh` — Publishes a `.so` for each Android ABI using the NDK toolchain, then packages them into an AAR with the `jni/<abi>/lib*.so` layout.

## Build

```bash
./build_xcframework.sh   # → MyNativeAOTApple/MyNativeAOTApple/NativeAotLib.xcframework
./build_aar.sh           # → MyNativeAOTAndroid/app/libs/NativeAotLib.aar
```

Then open the corresponding project in Xcode / Android Studio and run the app.

## Notes

- Android currently builds only `android-arm64` and `android-x64`. `android-arm` and `android-x86` are excluded because they cannot be cross-compiled on Apple Silicon hosts.
- `ANDROID_NDK_ROOT` in `build_aar.sh` is hard-coded to a local path; adjust if your environment differs.
- The Android bridge uses JNA for now. Replacing it with direct JNI using `CriticalNative` is under investigation to avoid the reflection overhead.
