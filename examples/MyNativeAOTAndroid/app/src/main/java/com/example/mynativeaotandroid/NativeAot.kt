package com.example.mynativeaotandroid

import dalvik.annotation.optimization.CriticalNative

object NativeAot {
    init {
        // C# Native AOT library — must be loaded first so aot_jni's JNI_OnLoad can resolve its symbols.
        System.loadLibrary("NativeAotLib")
        // JNI shim — registers natives on this object via RegisterNatives.
        System.loadLibrary("aot_jni")
    }

    @JvmStatic
    @CriticalNative
    external fun aotsample_add(a: Int, b: Int): Int

    @JvmStatic
    external fun aotsample_write_line(s: String): Int

    @JvmStatic
    external fun aotsample_sumstring(a: String, b: String): String?

    fun add(a: Int, b: Int): Int = aotsample_add(a, b)

    fun writeLine(message: String): Boolean = aotsample_write_line(message) == 0

    fun sumString(str1: String, str2: String): String? = aotsample_sumstring(str1, str2)
}
