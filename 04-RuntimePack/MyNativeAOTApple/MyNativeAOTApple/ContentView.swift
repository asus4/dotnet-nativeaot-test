//
//  ContentView.swift
//  MyNativeAOTTest
//
//  Created by Koki Ibukuro on 12.01.26.
//

import SwiftUI

struct ContentView: View {
    @State private var sumResult: String = ""

    var body: some View {
        VStack {
            Text("15 + 2 = \(aotsample_add(15, 2))")

            Button("Write Line") {
                aotsample_write_line("Hello from Swift!")
            }

            Button("Sum String") {
                if let cString = aotsample_sumstring("Hello, ", "World!") {
                    sumResult = String(cString: cString)
                    free(cString)
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
