# Native AOT Library Example

A minimal example of using .NET Native AOT as a native library on iOS / macOS and Android.

## How to test

```bash
# Apple (macOS / iOS / iOS simulator → xcframework)
./build/build_apple.sh
# Then open examples/MyNativeAOTApple/MyNativeAOTTApple.xcodeproj in Xcode and run.

# Android (arm64-v8a + x86_64 → jniLibs)
./build/build_android.sh
# Then open examples/MyNativeAOTAndroid in Android Studio and run.
```

## References

- List of Runtime Identifiers (RIDs): <https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids>
- Native AOT iOS tutorial: <https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks>
