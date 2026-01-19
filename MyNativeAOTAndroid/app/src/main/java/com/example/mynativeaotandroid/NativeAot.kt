package com.example.mynativeaotandroid

import android.util.Log


object NativeAot {
    init {
        try {
            System.loadLibrary(LIB_NAME)
            val result = nativeInit()
            if (result!=0){
              throw RuntimeException("Native library initialization failed")
            }
            Log.d(TAG, "Native library loaded successfully")
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to load native library", e)
            throw RuntimeException("Native library initialization failed", e)
        }
    }

    private const val TAG = "NativeAot"
    private const val LIB_NAME = "nativeaot_jni"

    private external fun nativeInit(): Int

    // JNI native method declarations
    @JvmStatic
    @dalvik.annotation.optimization.CriticalNative
    private external fun nativeAdd(a: Int, b: Int): Int
    private external fun nativeWriteLine(message: String): Int
    private external fun nativeSumString(str1: String, str2: String): String?

    fun add(a: Int, b: Int): Int = nativeAdd(a, b)
    fun writeLine(message: String): Boolean = nativeWriteLine(message) == 0
    fun sumString(str1: String, str2: String): String? = nativeSumString(str1, str2)
}
