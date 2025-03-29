//
//  ALDeviceOrientation.swift
//  Pods
//
//  Created by Admin on 30/3/25.
//

import UIKit

public enum ALDeviceOrientation: Int {
    case unknown = 0
    case portrait = 1
    case landscape = 2

    /// Khởi tạo từ `UIInterfaceOrientation`
    public init(_ interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait, .portraitUpsideDown:
            self = .portrait
        case .landscapeLeft, .landscapeRight:
            self = .landscape
        case .unknown:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }

    /// Khởi tạo từ `UIDeviceOrientation`
    public init(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait, .portraitUpsideDown:
            self = .portrait
        case .landscapeLeft, .landscapeRight:
            self = .landscape
        case .unknown, .faceUp, .faceDown:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }

    /// Lấy orientation hiện tại
    public static var current: ALDeviceOrientation {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return ALDeviceOrientation(scene.interfaceOrientation)
        }
        return .unknown
    }
}
