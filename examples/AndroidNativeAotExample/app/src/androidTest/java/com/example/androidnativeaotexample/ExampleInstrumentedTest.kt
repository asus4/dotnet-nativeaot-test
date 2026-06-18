package com.example.androidnativeaotexample

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.ext.junit.runners.AndroidJUnit4

import org.junit.Test
import org.junit.runner.RunWith

import org.junit.Assert.*

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class ExampleInstrumentedTest {
  @Test
  fun useAppContext() {
    // Context of the app under test.
    val appContext = InstrumentationRegistry.getInstrumentation().targetContext
    assertEquals("com.example.androidnativeaotexample", appContext.packageName)
  }

  @Test
  fun nativeAotBridgeCallsExports() {
    assertEquals(17, NativeAot.add(15, 2))
    assertTrue(NativeAot.writeLine("Hello from instrumentation!"))
    assertEquals("Hello, World!", NativeAot.sumString("Hello, ", "World!"))
  }

  @Test
  fun httpGetReturnsResponse() {
    val latch = CountDownLatch(1)
    var result = ""

    // TODO: Support https. NativeAOT on Android has no working TLS backend.
    NativeAot.httpGet("http://example.com") { r ->
      result = r
      latch.countDown()
    }
    assertTrue("HTTP callback did not arrive within timeout", latch.await(15, TimeUnit.SECONDS))
    // C# returns "<status> <reason>\n<body>" on success, or "ERROR: ..." on failure.
    assertTrue("Expected a 200 response, got: $result", result.startsWith("200"))
  }
}
