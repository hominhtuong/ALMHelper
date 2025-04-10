//
//  AdLog.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import UIKit

public func AdLog(_ items: Any..., file: String = #file, line: Int = #line) {
    guard ALMHelper.shared.configs.logDebug else { return }
    #if DEBUG
        let p = file.components(separatedBy: "/").last ?? ""
        print("ALMHelper: \(p), Line: \(line), \(items)")
    #endif
}
