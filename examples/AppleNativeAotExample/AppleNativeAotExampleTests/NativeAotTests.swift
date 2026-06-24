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

    @Test func fibonacci() {
        // Exercises the NativeFib NuGet native package through the C# bridge.
        #expect(NativeAot.fibonacci(10) == 55)
        #expect(NativeAot.fibonacci(0) == 0)
    }

    @Test func globalizationProbes() {
        // DateTime.Now / GregorianCalendar work without ICU.
        #expect(NativeAot.now()?.contains("local=") == true)
        #expect(NativeAot.today()?.isEmpty == false)
        // Invariant mode: empty current culture, ja-JP creation blocked.
        let culture = NativeAot.culture()
        #expect(culture?.contains("current=''") == true)
        #expect(culture?.contains("createJaJP=CultureNotFoundException") == true)
    }

    @Test func httpGet() async {
        let result = await withCheckedContinuation { continuation in
            NativeAot.httpGet("https://example.com") { continuation.resume(returning: $0) }
        }
        // C# returns "<status> <reason>\n<body>" on success, or "ERROR: ..." on failure.
        #expect(result.hasPrefix("200"), "Expected a 200 response, got: \(result.prefix(80))")
    }
}
