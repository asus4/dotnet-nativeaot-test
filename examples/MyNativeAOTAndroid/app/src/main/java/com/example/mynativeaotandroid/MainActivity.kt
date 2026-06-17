package com.example.mynativeaotandroid

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
      )
    }
  }
}

@Composable
private fun NativeAotView(
    addResult: Int,
    onWriteLine: () -> Unit,
    onSumString: () -> String,
) {
  var sumResult by remember { mutableStateOf("") }

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
      }
    }
  }
}

@Composable
private fun ActionButton(text: String, onClick: () -> Unit) {
  Button(onClick = onClick) { Text(text) }
}

@Preview(showBackground = true)
@Composable
private fun NativeAotViewPreview() {
  NativeAotView(
      addResult = 17,
      onWriteLine = {},
      onSumString = { "Hello, World!" },
  )
}
