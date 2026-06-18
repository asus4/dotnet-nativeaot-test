package com.example.androidnativeaotexample

import android.os.Handler
import android.os.Looper
import android.system.Os
import dalvik.annotation.optimization.CriticalNative
import dalvik.annotation.optimization.FastNative

object NativeAot {
    fun interface HttpCallback {
        fun onResult(result: String)
    }

    init {
        // To use TLS, need to set this
        Os.setenv("SSL_CERT_DIR", "/system/etc/security/cacerts", true)

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

    // Not @FastNative: returns immediately but the callback arrives later on a .NET thread.
    @JvmStatic
    external fun aotsample_http_get(url: String, callback: HttpCallback)

    private val mainHandler = Handler(Looper.getMainLooper())

    fun add(a: Int, b: Int): Int = aotsample_add(a, b)

    fun writeLine(message: String): Boolean = aotsample_write_line(message) == 0

    fun sumString(str1: String, str2: String): String? = aotsample_sumstring(str1, str2)

    fun httpGet(url: String, onResult: (String) -> Unit) {
        aotsample_http_get(url) { result -> mainHandler.post { onResult(result) } }
    }
}
