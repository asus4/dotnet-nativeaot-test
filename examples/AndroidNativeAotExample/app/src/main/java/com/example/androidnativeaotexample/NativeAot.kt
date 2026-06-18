package com.example.androidnativeaotexample

import dalvik.annotation.optimization.CriticalNative
import dalvik.annotation.optimization.FastNative

object NativeAot {
    init {
        // Loads the JNI shim.
        // The C# NativeAOT lib is loaded automatically.
        System.loadLibrary("aot_jni")
    }

    @JvmStatic
    @CriticalNative
    external fun aotsample_add(a: Int, b: Int): Int

    @JvmStatic
    @FastNative
    external fun aotsample_write_line(s: String): Int

    @JvmStatic
    @FastNative
    external fun aotsample_sumstring(a: String, b: String): String?

    fun add(a: Int, b: Int): Int = aotsample_add(a, b)

    fun writeLine(message: String): Boolean = aotsample_write_line(message) == 0

    fun sumString(str1: String, str2: String): String? = aotsample_sumstring(str1, str2)
}
