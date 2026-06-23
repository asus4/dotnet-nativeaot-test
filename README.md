# .NET Native AOT Interop Test

A minimal example that builds an .NET code as a native library for iOS / macOS and Android. Use calls it from native Swift / Kotlin project.
The goal is to test a minimal workflow for C# -> native interop.

## Layout

- `src/NativeAotLib/`: Shared .NET library
- `tests/NativeAotLib.Tests/`: Pure C# (xUnit) tests for the library logic, no native build required
- `src/NativeFib/`: Sample native library, which statically links the matching `libnativefib.a` into the AOT build.
- `build/build_nativefib.sh`: Compiles the per-RID NativeFib static libs
- `build/build_apple.sh`: Generates xcframework for macOS / iOS
- `build/build_android.sh`: Generates .so files for Android
- `build/build_openssl_android.sh`: Builds OpenSSL (`libssl.so`/`libcrypto.so`) for Android
- `examples/AppleNativeAotExample/`: An example Xcode project.
- `examples/AndroidNativeAotExample/`: An example Android Studio project.

## How to Verify

```sh
# Compile the sample NativeFib static libs
./build/build_nativefib.sh

# Verify C# builds
dotnet build dotnet-nativeaot-test.slnx

# Run the pure C# tests
dotnet test

# Build xcframework for macOS / iOS and move it to the Xcode project
./build/build_apple.sh

# Run Apple interop tests on macOS if you have modified the Apple example.
./build/test_apple.sh

# Build OpenSSL for Android (once; required for HTTPS — see Notes).
./build/build_openssl_android.sh

# Build .so for Android and move it to the Android Studio project
./build/build_android.sh

# Run Android instrumented tests
cd examples/AndroidNativeAotExample && ./gradlew connectedAndroidTest
```

## Documents

- Reducing binary size: [docs/reducing-binary-size.md](docs/reducing-binary-size.md)

## References

- [NativeAOT documents](https://github.com/dotnet/runtime/blob/main/src/coreclr/nativeaot/docs/android).
  - Android HTTPS / TLS: [Android-Bionic](https://github.com/dotnet/runtime/blob/main/src/coreclr/nativeaot/docs/android-bionic.md)
- List of Runtime Identifiers (RIDs): <https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids>
- Native AOT iOS tutorial: <https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks>
