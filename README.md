# .NET Native AOT Interop Test

A minimal example that builds an .NET code as a native library for iOS / macOS and Android. Use calls it from native Swift / Kotlin project.
The goal is to test a minimal workflow for C# -> native interop.

## Layout

- `src/NativeAotLib/`: Shared .NET library
- `build/build_apple.sh`: Generates xcframework for macOS / iOS
- `build/build_android.sh`: Generates .so files for Android
- `examples/AppleNativeAotExample/`: An example Xcode project.
- `examples/AndroidNativeAotExample/`: An example Android Studio project.

## How to Verify

```sh

# Build xcframework for macOS / iOS and move it to the Xcode project
./build/build_apple.sh

# Run Apple interop tests on macOS if you have modified the Apple example.
./build/test_apple.sh

# Build .so for Android and move it to the Android Studio project
./build/build_android.sh

# Run Android instrumented tests if you have modified the android.
cd examples/AndroidNativeAotExample && ./gradlew connectedAndroidTest
```

## References

- List of Runtime Identifiers (RIDs): <https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids>
- Native AOT iOS tutorial: <https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks>
