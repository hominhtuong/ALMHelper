//
//  AdDisplayState.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 12/3/25.
//

@objc public class AdDisplayState: NSObject, @unchecked Sendable {
    @objc public static let notReady = AdDisplayState(state: 0)
    @objc public static let failed = AdDisplayState(state: 1)
    @objc public static let showed = AdDisplayState(state: 2)
    @objc public static let hidden = AdDisplayState(state: 3)

    @objc public static func didReward(_ amount: Int) -> AdDisplayState {
        return AdDisplayRewardState(amount)
    }

    @objc public let state: Int
    @objc public let rewardAmount: Int

    public var isReward: Bool {
        return self is AdDisplayRewardState
    }

    public init(state: Int, rewardAmount: Int = 0) {
        self.state = state
        self.rewardAmount = rewardAmount
    }

    public var title: String {
        switch state {
        case 0: return "notReady"
        case 1: return "failed"
        case 2: return "showed"
        case 3: return "hidden"
        default: return "unknown"
        }
    }
}

@objc public class AdDisplayRewardState: AdDisplayState, @unchecked Sendable {
    @objc public init(_ amount: Int) {
        super.init(state: 4, rewardAmount: amount)
    }
}
