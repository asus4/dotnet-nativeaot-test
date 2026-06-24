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
    // Exercises the NativeFib NuGet native package through the C# bridge.
    assertEquals(55L, NativeAot.fibonacci(10))
    assertEquals(0L, NativeAot.fibonacci(0))
  }

  @Test
  fun globalizationProbesReportInvariantBehavior() {
    // DateTime.Now / GregorianCalendar work without ICU.
    assertTrue(NativeAot.now()?.contains("local=") == true)
    assertFalse(NativeAot.today().isNullOrEmpty())
    // Invariant mode: empty current culture, ja-JP creation blocked.
    val culture = NativeAot.culture()
    assertTrue("culture was: $culture", culture?.contains("current=''") == true)
    assertTrue("culture was: $culture", culture?.contains("createJaJP=CultureNotFoundException") == true)
  }

  @Test
  fun httpGetReturnsResponse() {
    val latch = CountDownLatch(1)
    var result = ""

    NativeAot.httpGet("https://example.com") { r ->
      result = r
      latch.countDown()
    }
    assertTrue("HTTP callback did not arrive within timeout", latch.await(15, TimeUnit.SECONDS))
    // C# returns "<status> <reason>\n<body>" on success, or "ERROR: ..." on failure.
    assertTrue("Expected a 200 response, got: $result", result.startsWith("200"))
  }
}
