//
//  ContentView.swift
//  AppleNativeAotExample
//
//  Created by Koki Ibukuro on 12.01.26.
//

import SwiftUI

struct ContentView: View {
    @State private var sumResult: String = ""
    @State private var fibResult: String = ""
    @State private var httpResult: String = ""
    @State private var isHttpLoading: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Text("15 + 2 = \(NativeAot.add(15, 2))")

            Button("Write Line") {
                NativeAot.writeLine("Hello from Swift!")
            }

            Button("Sum String") {
                if let result = NativeAot.sumString("Hello, ", "World!") {
                    sumResult = result
                }
            }

            Text(sumResult)

            Button("Fibonacci") {
                fibResult = "fib(10) = \(NativeAot.fibonacci(10))"
            }

            Text(fibResult)

            Button("HTTP GET") {
                isHttpLoading = true
                httpResult = "Loading…"
                NativeAot.httpGet("https://example.com") { result in
                    httpResult = String(result.prefix(200))
                    isHttpLoading = false
                }
            }
            .disabled(isHttpLoading)

            Text(httpResult)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
