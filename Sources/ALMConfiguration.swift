//
//  ALMConfiguration.swift
//  ALMHelper
//
//  Created by Admin on 11/3/25.
//

public class ALMConfiguration {
    ///default is 0 - alway request ads
    public var frequencyCapping: Int = 0

    ///default is 100% - alway show
    public var impressionPercentage: Int = 100
    
    public var enableAds = false
    public var showAoa = false
    public var showResume = false
    public var showInterstitial = false
    public var showReward = false
    
    public var retryAfterFailed: Bool = true
    public var loadAdAfterShowed: Bool = true
    public var loadNativeAfterExpire: Bool = true
}

