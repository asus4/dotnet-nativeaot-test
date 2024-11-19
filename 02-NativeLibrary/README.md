# Native Library

```sh
# Make new project
dotnet new console -o NativeLibrary --aot

# Make executable app
cd NativeLibrary
# Build dynamic lib
dotnet publish --use-current-runtime
# Build static lib
dotnet publish /p:NativeLib=Static --use-current-runtime

```
