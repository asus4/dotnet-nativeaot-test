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
    private external fun aotsample_add(a: Int, b: Int): Int

    // Computes Fibonacci via the NativeFib NuGet native package (statically linked into the C# lib).
    @JvmStatic
    @CriticalNative
    private external fun aotsample_fibonacci(n: Int): Long

    @JvmStatic
    @FastNative
    private external fun aotsample_write_line(s: String): Int

    @JvmStatic
    @FastNative
    private external fun aotsample_sumstring(a: String, b: String): String?

    // Not @FastNative: returns immediately but the callback arrives later on a .NET thread.
    @JvmStatic
    private external fun aotsample_http_get(url: String, callback: HttpCallback)

    // Globalization probes: each returns a diagnostic string built in C#.
    @JvmStatic
    @FastNative
    private external fun aotsample_now(): String?

    @JvmStatic
    @FastNative
    private external fun aotsample_today(): String?

    @JvmStatic
    @FastNative
    private external fun aotsample_culture(): String?

    private val mainHandler = Handler(Looper.getMainLooper())

    fun add(a: Int, b: Int): Int = aotsample_add(a, b)

    fun fibonacci(n: Int): Long = aotsample_fibonacci(n)

    fun writeLine(message: String): Boolean = aotsample_write_line(message) == 0

    fun sumString(str1: String, str2: String): String? = aotsample_sumstring(str1, str2)

    fun httpGet(url: String, onResult: (String) -> Unit) {
        aotsample_http_get(url) { result -> mainHandler.post { onResult(result) } }
    }

    fun now(): String? = aotsample_now()

    fun today(): String? = aotsample_today()

    fun culture(): String? = aotsample_culture()
}
