package com.example.androidnativeaotexample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    setContent {
      NativeAotView(
          addResult = NativeAot.add(15, 2),
          onWriteLine = { NativeAot.writeLine("Hello from Kotlin!") },
          onSumString = { NativeAot.sumString("Hello, ", "World!") ?: "" },
          onFibonacci = { "fib(10) = ${NativeAot.fibonacci(10)}" },
      )
    }
  }
}

@Composable
private fun NativeAotView(
    addResult: Int,
    onWriteLine: () -> Unit,
    onSumString: () -> String,
    onFibonacci: () -> String,
) {
  var sumResult by remember { mutableStateOf("") }
  var fibResult by remember { mutableStateOf("") }
  var httpResult by remember { mutableStateOf("") }
  var isHttpLoading by remember { mutableStateOf(false) }

  Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
    Box(modifier = Modifier.fillMaxSize().padding(innerPadding)) {
      Column(
          modifier = Modifier.align(Alignment.Center).padding(horizontal = 16.dp),
          verticalArrangement = Arrangement.spacedBy(32.dp),
          horizontalAlignment = Alignment.CenterHorizontally,
      ) {
        Text(text = "15 + 2 = $addResult")
        ActionButton(text = "Write Logcat from C#", onClick = onWriteLine)
        ActionButton(text = "Sum Strings in C#", onClick = { sumResult = onSumString() })
        Text(text = sumResult)
        ActionButton(text = "Fibonacci in C#", onClick = { fibResult = onFibonacci() })
        Text(text = fibResult)
        ActionButton(
            text = "HTTP GET in C#",
            enabled = !isHttpLoading,
            onClick = {
              isHttpLoading = true
              httpResult = "Loading…"
              NativeAot.httpGet("https://example.com") { result ->
                httpResult = result.take(200)
                isHttpLoading = false
              }
            },
        )
        Text(text = httpResult)
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
  NativeAotView(
      addResult = 17,
      onWriteLine = {},
      onSumString = { "Hello, World!" },
      onFibonacci = { "fib(10) = 55" },
  )
}
