# Native AOT Library Example

A minimum example of using .Net Native AOT as a native library in iOS, macOS (from Swift), Android (from Kotlin).

## How to test

```bash
# Build iOS and macOS xcframework
./build_xcframeworks.sh
# Then open MyNativeAOTApple/MyNativeAOTApple.xcodeproj with Xcode to test macOS/iOS app

# Build Android AAR
./build_aar.sh
# Then open MyNativeAOTAndroid with Android Studio to test Android app
```

## Links

- List of Runtime Identifiers (RIDs): <https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids>
- Native AOT iOS tutorial: <https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks>
