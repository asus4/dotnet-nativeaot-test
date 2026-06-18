//
//  ContentView.swift
//  AppleNativeAotExample
//
//  Created by Koki Ibukuro on 12.01.26.
//

import SwiftUI

struct ContentView: View {
    @State private var sumResult: String = ""

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

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
