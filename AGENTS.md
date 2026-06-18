# .NET Native AOT Interop Test

A minimal example that builds an .NET code as a native library for iOS / macOS and Android. Use calls it from native Swift / Kotlin project.
The goal is to test a minimal workflow for C# -> native interop.

## Layout

- `src/NativeAotLib/`: Shared .NET library
- `build/build_apple.sh`: Generates xcframework for macOS / iOS
- `build/build_android.sh`: Generates .so files for Android
- `examples/MyNativeAOTApple/`: An example Xcode project.
- `examples/MyNativeAOTAndroid/`: An example Android Studio project.

## How to Verify

```sh

# Build xcframework for macOS / iOS and move it to the Xcode project
./build/build_apple.sh

# Build .so for Android and move it to the Android Studio project
./build/build_android.sh

# Run Android instrumented tests if you have modified the android.
cd examples/MyNativeAOTAndroid && ./gradlew connectedAndroidTest
```
