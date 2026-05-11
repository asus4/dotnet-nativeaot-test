cmake_minimum_required(VERSION 3.22.1)
project(aot_jni C)

# libNativeAotLib.so (built by .NET Native AOT) is loaded at runtime via dlopen
# in JNI_OnLoad — not link-time. The AOT-built ELF has no SONAME, which causes
# the linker to bake the absolute build-host path into DT_NEEDED, breaking
# loading on the device.
add_library(aot_jni SHARED aot_jni.c)
target_include_directories(aot_jni PRIVATE
    ${CMAKE_SOURCE_DIR}/../../../../../include)
target_link_libraries(aot_jni PRIVATE log)

# 16 KB ELF page size for Android 15+ devices with 16 KB pages.
target_link_options(aot_jni PRIVATE "-Wl,-z,max-page-size=16384")
