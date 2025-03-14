//
//  AdDisplayState.swift
//  ALMHelper
//
//  Created by Admin on 12/3/25.
//

public enum AdDisplayState: Equatable {
    public static func == (lhs: AdDisplayState, rhs: AdDisplayState) -> Bool {
        switch (lhs, rhs) {
        case (.notReady, .notReady), (.failed, .failed), (.showed, .showed),
            (.hidden, .hidden):
            return true
        case (.didReward(let a), .didReward(let b)):
            return a == b
        default:
            return false
        }
    }
    case notReady
    case failed
    case showed
    case hidden
    case didReward(_ amount: Int)
}
