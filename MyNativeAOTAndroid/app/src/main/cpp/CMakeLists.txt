cmake_minimum_required(VERSION 3.22.1)

project("nativeaot_jni")

# Add the JNI wrapper library
add_library(nativeaot_jni SHARED nativeaot_jni.c)

target_include_directories(nativeaot_jni PRIVATE
    ../../../../../NativeAotLib/include)

target_link_libraries(nativeaot_jni
    log
    dl)
