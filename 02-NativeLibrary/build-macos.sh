#!/bin/bash -xe

dotnet restore -r osx-arm64
dotnet publish -c Release

# Need to rename NativeLibrary.a to libNativeLibrary.a to link with clang
mv bin/Release/net9.0/osx-arm64/publish/NativeLibrary.a bin/Release/net9.0/osx-arm64/publish/libNativeLibrary.a

# Build main.c with link NativeLib.a
clang main.c -I./include -L./bin/Release/net9.0/osx-arm64/publish -lNativeLibrary -o main
# ./main
