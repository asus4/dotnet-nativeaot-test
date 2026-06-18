//
//  NativeAotTests.swift
//  AppleNativeAotExampleTests
//
//  Created by Koki Ibukuro on 12.01.26.
//

import Testing
@testable import AppleNativeAotExample

struct NativeAotTests {
    @Test func add() {
        #expect(NativeAot.add(15, 2) == 17)
    }

    @Test func writeLine() {
        #expect(NativeAot.writeLine("Hello from Swift Testing!"))
    }

    @Test func sumString() {
        #expect(NativeAot.sumString("Hello, ", "World!") == "Hello, World!")
    }

    @Test func httpGet() async {
        let result = await withCheckedContinuation { continuation in
            NativeAot.httpGet("https://example.com") { continuation.resume(returning: $0) }
        }
        // C# returns "<status> <reason>\n<body>" on success, or "ERROR: ..." on failure.
        #expect(result.hasPrefix("200"), "Expected a 200 response, got: \(result.prefix(80))")
    }
}
