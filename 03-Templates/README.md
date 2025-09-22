# dotnet templates Test

```sh
# You need to install workload for platforms
sudo dotnet workload install ios macos android --version 9.0.305

# Find dotnet templates
dotnet new list 
dotnet new search "keyword" 

# Make projects from templates
dotnet new androidlib -o AndroidLibTest
dotnet new android -o AndroidTest
dotnet new ioslib -o iOSLibTest
dotnet new ios -o iOSTest
dotnet new macoslib -o MacOSLibTest
dotnet new macos -o MacOSTest
```
