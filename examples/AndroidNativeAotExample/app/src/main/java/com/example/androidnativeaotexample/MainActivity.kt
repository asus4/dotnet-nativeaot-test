package com.example.androidnativeaotexample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    setContent { NativeAotView() }
  }
}

@Composable
private fun NativeAotView() {
  var log by remember { mutableStateOf("") }
  var isHttpLoading by remember { mutableStateOf(false) }
  val scrollState = rememberScrollState()
  val buttonsScrollState = rememberScrollState()

  fun append(line: String) {
    log = if (log.isEmpty()) line else log + "\n" + line
  }

  LaunchedEffect(log) {
    if (log.isNotEmpty()) {
      scrollState.animateScrollTo(scrollState.maxValue)
    }
  }

  Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
    Column(modifier = Modifier.fillMaxSize().padding(innerPadding)) {
      Text(
          text = "C# NativeAOT Test",
          style = MaterialTheme.typography.headlineMedium,
          modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
          textAlign = TextAlign.Center,
      )

      Column(
          modifier =
              Modifier.weight(0.7f)
                  .fillMaxWidth()
                  .verticalScroll(buttonsScrollState)
                  .padding(horizontal = 16.dp),
          verticalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterVertically),
          horizontalAlignment = Alignment.CenterHorizontally,
      ) {
        ActionButton(
            text = "Random Add",
            onClick = {
              val a = (0..100).random()
              val b = (0..100).random()
              append("$a + $b = ${NativeAot.add(a, b)}")
            },
        )
        ActionButton(
            text = "Write Logcat",
            onClick = {
              NativeAot.writeLine("Hello from Kotlin!")
              append("writeLine: Hello from Kotlin!")
            },
        )
        ActionButton(
            text = "Sum Strings",
            onClick = { append(NativeAot.sumString("Hello, ", "World!") ?: "") },
        )
        ActionButton(
            text = "Fibonacci",
            onClick = {
              val n = (1..20).random()
              append("fib($n) = ${NativeAot.fibonacci(n)}")
            },
        )
        ActionButton(
            text = "HTTP GET",
            enabled = !isHttpLoading,
            onClick = {
              isHttpLoading = true
              append("Loading…")
              NativeAot.httpGet("https://example.com") { result ->
                append(result.take(200))
                isHttpLoading = false
              }
            },
        )
        ActionButton(
            text = "Clock Now",
            onClick = { NativeAot.now()?.let { append(it) } },
        )
        ActionButton(
            text = "Calendar Today",
            onClick = { NativeAot.today()?.let { append("today: $it") } },
        )
        ActionButton(
            text = "Culture",
            onClick = { NativeAot.culture()?.let { append(it) } },
        )
      }

      Column(
          modifier =
              Modifier.weight(0.3f)
                  .fillMaxWidth()
                  .border(1.dp, MaterialTheme.colorScheme.outlineVariant)
                  .verticalScroll(scrollState)
                  .padding(8.dp),
      ) {
        Text(text = log, fontFamily = FontFamily.Monospace)
      }
    }
  }
}

@Composable
private fun ActionButton(text: String, enabled: Boolean = true, onClick: () -> Unit) {
  Button(onClick = onClick, enabled = enabled) { Text(text) }
}

@Preview(showBackground = true)
@Composable
private fun NativeAotViewPreview() {
  NativeAotView()
}
