package com.example.mynativeaotandroid

import com.sun.jna.Library
import com.sun.jna.Native
import com.sun.jna.Pointer

interface NativeAotBridge : Library {
    companion object {
        val INSTANCE: NativeAotBridge by lazy {
            Native.load("NativeAotLib", NativeAotBridge::class.java)
        }
    }

    // int aotsample_add(int a, int b)
    fun aotsample_add(a: Int, b: Int): Int

    // int aotsample_write_line(const char* pString)
    fun aotsample_write_line(pString: String): Int

    // char* aotsample_sumstring(const char* pStr1, const char* pStr2)
    fun aotsample_sumstring(pStr1: String, pStr2: String): Pointer?
}
