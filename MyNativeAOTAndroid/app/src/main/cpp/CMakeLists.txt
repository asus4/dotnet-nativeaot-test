cmake_minimum_required(VERSION 3.22.1)
project(aot_jni C)

set(JNI_LIBS ${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})

add_library(NativeAotLib SHARED IMPORTED)
set_target_properties(NativeAotLib PROPERTIES
    IMPORTED_LOCATION ${JNI_LIBS}/libNativeAotLib.so)

add_library(aot_jni SHARED aot_jni.c)
target_include_directories(aot_jni PRIVATE
    ${CMAKE_SOURCE_DIR}/../../../../../include)
target_link_libraries(aot_jni PRIVATE NativeAotLib log)
