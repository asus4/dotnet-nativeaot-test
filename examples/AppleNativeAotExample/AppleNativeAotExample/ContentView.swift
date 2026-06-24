//
//  ContentView.swift
//  AppleNativeAotExample
//
//  Created by Koki Ibukuro on 12.01.26.
//

import SwiftUI

struct ContentView: View {
    @State private var log: String = ""
    @State private var isHttpLoading: Bool = false
    private let logBottomId = "LOG_BOTTOM"

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Text("C# NativeAOT Test")
                    .font(.title)
                    .padding(.top)

                VStack(spacing: 16) {
                    Button("Random Add") {
                        let a = Int32.random(in: 0...100)
                        let b = Int32.random(in: 0...100)
                        append("\(a) + \(b) = \(NativeAot.add(a, b))")
                    }

                    Button("Write Line") {
                        NativeAot.writeLine("Hello from Swift!")
                        append("writeLine: Hello from Swift!")
                    }

                    Button("Sum String") {
                        if let result = NativeAot.sumString("Hello, ", "World!") {
                            append(result)
                        }
                    }

                    Button("Fibonacci") {
                        let n = Int32.random(in: 1...20)
                        append("fib(\(n)) = \(NativeAot.fibonacci(n))")
                    }

                    Button("HTTP GET") {
                        isHttpLoading = true
                        append("Loading…")
                        NativeAot.httpGet("https://example.com") { result in
                            append(String(result.prefix(200)))
                            isHttpLoading = false
                        }
                    }
                    .disabled(isHttpLoading)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ScrollViewReader { proxy in
                    ScrollView {
                        Text(log)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                        Color.clear.frame(height: 1).id(logBottomId)
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.3)
                    .background(Color.secondary.opacity(0.05))
                    .overlay(Rectangle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                    .onChange(of: log) { _, _ in
                        withAnimation { proxy.scrollTo(logBottomId, anchor: .bottom) }
                    }
                }
            }
        }
    }

    private func append(_ line: String) {
        log += log.isEmpty ? line : "\n" + line
    }
}

#Preview {
    ContentView()
}
