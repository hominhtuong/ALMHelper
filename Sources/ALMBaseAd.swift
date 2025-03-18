//
//  ALMBaseAd.swift
//  ALMHelper
//
//  Created by Admin on 18/3/25.
//

import AppLovinSDK
import MiTuKit

@objc public protocol ALMAdProtocol {
    @objc func loadAd()
    @objc func showAds(placement: String, _ completion: ((AdDisplayState) -> Void)?)
}

public class ALMBaseAd: NSObject {
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init()
    }
    
    public var isAdReady: Bool {
        return false
    }
    
    internal var placement: String = ""
    internal let adUnitId: String
    internal var retryAttempt = 0.0
    internal var adCompletionHandle: ((AdDisplayState) -> Void)?
    
    internal weak var delegate: ALMHelperDelegate?
    
    internal var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
    
}

extension ALMBaseAd: ALMAdProtocol {
    public func loadAd() { }
    public func showAds(placement: String, _ completion: ((AdDisplayState) -> Void)?) {}
}
