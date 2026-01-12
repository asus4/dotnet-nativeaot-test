//
//  ContentView.swift
//  MyNativeAOTTest
//
//  Created by Koki Ibukuro on 12.01.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("15 + 2 = \(aotsample_add(15, 2))")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
