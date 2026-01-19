package com.example.mynativeaotandroid

import android.util.Log
import com.sun.jna.Native
import com.sun.jna.Pointer

object NativeAot {
    private const val TAG = "NativeAot"
    private val bridge = NativeAotBridge.INSTANCE

    init {
        try {
            // Verify native library loaded correctly with a simple test call
            bridge.aotsample_add(1, 1)
            Log.d(TAG, "Native library loaded successfully")
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "Failed to load native library", e)
            throw RuntimeException("Native library initialization failed", e)
        }
    }

    fun add(a: Int, b: Int): Int = bridge.aotsample_add(a, b)

    fun writeLine(message: String): Boolean = bridge.aotsample_write_line(message) == 0

    fun sumString(str1: String, str2: String): String? {
        val resultPointer = bridge.aotsample_sumstring(str1, str2) ?: return null
        return try {
            resultPointer.getString(0, "UTF-8")
        } finally {
            // Critical: Free memory allocated by C code (same as iOS free())
            Native.free(Pointer.nativeValue(resultPointer))
        }
    }
}
