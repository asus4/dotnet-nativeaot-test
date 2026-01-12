# Runtime pack test

Test of the document: [[https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/ios-like-platforms/creating-and-consuming-custom-frameworks]]

```bash
dotnet new classlib -n "MyNativeAOTLibrary"

dotnet publish -r osx-x64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r osx-arm64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r ios-arm64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r iossimulator-arm64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r iossimulator-x64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj

dotnet publish -r android-arm64 MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r android-arm MyNativeAOTLibrary/MyNativeAOTLibrary.csproj

dotnet publish -r linux-bionic-arm64 /p:SysDvrTarget=android MyNativeAOTLibrary/MyNativeAOTLibrary.csproj
dotnet publish -r linux-bionic-arm64 -p:DisableUnsupportedError=true -p:PublishAotUsingRuntimePack=true MyNativeAOTLibrary/MyNativeAOTLibrary.csproj

# List of RIDs
# https://learn.microsoft.com/en-us/dotnet/core/rid-catalog#known-rids
# osx-x64 (Minimum OS version is macOS 10.12 Sierra)
# osx-arm64
# ios-arm64, iossimulator-arm64 or iossimulator-x64
# maccatalyst-arm64 or maccatalyst-x64
# tvos-arm64, tvossimulator-arm64 or tvossimulator-x64

mkdir MyNativeAOTLibrary.framework

lipo -create MyNativeAOTLibrary/bin/Release/net10.0/ios-arm64/publish/MyNativeAOTLibrary.dylib -output MyNativeAOTLibrary.framework/MyNativeAOTLibrary
touch MyNativeAOTLibrary.framework/Info.plist

mkdir -p MyNativeAOTLibrary.framework/Versions/A/Resources
ln -sfh Versions/Current/MyNativeAOTLibrary MyNativeAOTLibrary.framework/MyNativeAOTLibrary
ln -sfh Versions/Current/Resources MyNativeAOTLibrary.framework/Resources
ln -sfh A MyNativeAOTLibrary.framework/Versions/Current
```
