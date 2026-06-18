//
//  NativeAot.swift
//  AppleNativeAotExample
//
//  Created by Koki Ibukuro on 12.01.26.
//

import Foundation

/// Swift wrapper over the NativeAotLib C exports (see aot_nativemethods.h).
enum NativeAot {
    static func add(_ a: Int32, _ b: Int32) -> Int32 {
        aotsample_add(a, b)
    }

    /// Computes the n-th Fibonacci number via the NativeFib NuGet native package
    /// (C# export -> statically linked native code).
    static func fibonacci(_ n: Int32) -> Int64 {
        aotsample_fibonacci(n)
    }

    @discardableResult
    static func writeLine(_ message: String) -> Bool {
        aotsample_write_line(message) == 0
    }

    static func sumString(_ a: String, _ b: String) -> String? {
        guard let cString = aotsample_sumstring(a, b) else { return nil }
        defer { free(cString) }
        return String(cString: cString)
    }

    /// Holds the pending HTTP completion. The C callback can't capture context, so we stash it
    /// here. Only one request runs at a time (the UI button is disabled while loading), so a
    /// single slot is sufficient.
    private static var pendingHttpCompletion: ((String) -> Void)?

    /// Performs an async HTTP GET in C# and delivers the result on the main queue.
    static func httpGet(_ url: String, completion: @escaping (String) -> Void) {
        pendingHttpCompletion = completion
        aotsample_http_get(url) { result in
            // Runs on a background (.NET) thread; `result` is only valid during this call.
            let text = result.map { String(cString: $0) } ?? ""
            DispatchQueue.main.async {
                let completion = NativeAot.pendingHttpCompletion
                NativeAot.pendingHttpCompletion = nil
                completion?(text)
            }
        }
    }
}
