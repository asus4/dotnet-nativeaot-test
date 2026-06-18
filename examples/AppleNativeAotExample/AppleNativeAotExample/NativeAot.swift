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

    @discardableResult
    static func writeLine(_ message: String) -> Bool {
        aotsample_write_line(message) == 0
    }

    static func sumString(_ a: String, _ b: String) -> String? {
        guard let cString = aotsample_sumstring(a, b) else { return nil }
        defer { free(cString) }
        return String(cString: cString)
    }
}
