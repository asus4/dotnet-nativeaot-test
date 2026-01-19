package com.example.mynativeaotandroid

import android.util.Log

object NativeAot {
    private const val TAG = "NativeAot"
    private val bridge = NativeAotBridge()

    init {
        try {
            // Verify native library loaded correctly with a simple test call
            bridge.nativeAdd(1, 1)
            Log.d(TAG, "Native library loaded successfully")
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to load native library", e)
            throw RuntimeException("Native library initialization failed", e)
        }
    }

    fun add(a: Int, b: Int): Int = bridge.nativeAdd(a, b)

    fun writeLine(message: String): Boolean = bridge.nativeWriteLine(message) == 0

    fun sumString(str1: String, str2: String): String? = bridge.nativeSumString(str1, str2)
}
