//
//  AdLog.swift
//  ALMHelper
//
//  Created by Admin on 11/3/25.
//

import UIKit

public func AdLog(_ items: Any..., file: String = #file, line: Int = #line) {
    #if DEBUG
        let p = file.components(separatedBy: "/").last ?? ""
        print("ALMHelper: \(p), Line: \(line), \(items)")
    #endif
}
