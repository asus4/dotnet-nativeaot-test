# .NET Native AOT Interop Test

A minimal example that builds an .NET code as a native library for iOS / macOS and Android. Use calls it from native Swift / Kotlin project.
The goal is to test a minimal workflow for C# -> native interop.

## How to test

```bash
# Apple (macOS / iOS / iOS simulator → xcframework)
./build/build_apple.sh
# Then open examples/AppleNativeAotExample/AppleNativeAotExample.xcodeproj in Xcode and run.

# Android (arm64-v8a + x86_64 → jniLibs)
./build/build_android.sh
# Then open examples/AndroidNativeAotExample in Android Studio and run.
```

## References

- List of Runtime Identifiers (RIDs): <https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids>
- Native AOT iOS tutorial: <https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks>
