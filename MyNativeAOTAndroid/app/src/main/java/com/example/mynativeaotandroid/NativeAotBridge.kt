package com.example.mynativeaotandroid

class NativeAotBridge {
    companion object {
        init {
            // Load the JNI wrapper (it will load NativeAotLib internally via dlopen)
            System.loadLibrary("nativeaot_jni")
        }
    }

    // JNI native method declarations
    external fun nativeAdd(a: Int, b: Int): Int
    external fun nativeWriteLine(message: String): Int
    external fun nativeSumString(str1: String, str2: String): String?
}
