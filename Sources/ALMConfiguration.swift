//
//  ALMConfiguration.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import UIKit

public class ALMConfiguration {
    ///default is 0 - alway request ads
    public var frequencyCapping: Int = 0

    ///default is 100% - alway show
    public var impressionPercentage: Int = 100
    
    /// Time between Open and Interstitial
    public var timeBetweenAds: Int = 5
    
    public var enableAds = true
    public var showAoa = true
    public var showResume = true
    public var showInterstitial = true
    public var showReward = true
    
    public var retryAfterFailed: Bool = true
    public var loadAdAfterShowed: Bool = true
    public var loadNativeAfterExpire: Bool = true
    
    public var forceOrientationAd: Bool = true
    public var orientation: UIDeviceOrientation = .portrait
}

