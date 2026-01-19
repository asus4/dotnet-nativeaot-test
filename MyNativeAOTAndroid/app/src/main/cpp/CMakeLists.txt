cmake_minimum_required(VERSION 3.22.1)

project("nativeaot_jni")

# Add the JNI wrapper library
add_library(nativeaot_jni SHARED nativeaot_jni.c)

# Link against the NativeAotLib shared library
# NATIVEAOTLIB_DIR is passed from the build script
target_link_libraries(nativeaot_jni
    ${NATIVEAOTLIB_DIR}/libNativeAotLib.so
    log)
