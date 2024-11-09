# Hello World

```sh
# Make new project
dotnet new console -o HelloWorld --aot

# Make executable app
cd HelloWorld
dotnet publish

# Run app for macOS-arm64
./bin/Release/net8.0/osx-arm64/HelloWorld
./bin/Release/net8.0/osx-arm64/publish/HelloWorld
./bin/Release/net8.0/osx-arm64/native/HelloWorld
# Check info of the binary
lipo -info ./bin/Release/net8.0/osx-arm64/HelloWorld
```
