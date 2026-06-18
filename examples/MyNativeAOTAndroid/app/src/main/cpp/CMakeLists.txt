cmake_minimum_required(VERSION 3.22.1)
project(aot_jni C)

# link libNativeAotLib.so
add_library(NativeAotLib SHARED IMPORTED)
set_target_properties(NativeAotLib PROPERTIES IMPORTED_LOCATION
    ${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libNativeAotLib.so)

add_library(aot_jni SHARED aot_jni.c)
target_include_directories(aot_jni PRIVATE
    ${CMAKE_SOURCE_DIR}/../../../../../../src/NativeAotLib/include)
target_link_libraries(aot_jni PRIVATE NativeAotLib log)

# 16 KB ELF page size for Android 15+.
target_link_options(aot_jni PRIVATE "-Wl,-z,max-page-size=16384")
