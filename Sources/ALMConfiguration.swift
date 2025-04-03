//
//  ALMConfiguration.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import UIKit

public class ALMConfiguration {
    /// Default is 0 - Always request ads without frequency capping.
    public var frequencyCapping: Int = 0

    /// Default is 100% - Ads will always be shown.
    public var impressionPercentage: Int = 100
    
    /// Minimum time interval (in seconds) between Open Ad and Interstitial Ad.
    public var timeBetweenAds: Int = 5
    
    /// Enable or disable ads globally.
    public var enableAds = true

    /// Enable or disable App Open Ads (AOA).
    public var showAoa = true
    
    /// Enable or disable Resume Ads.
    public var showResume = true
    
    /// Enable or disable Interstitial Ads.
    public var showInterstitial = true
    
    /// Enable or disable Rewarded Ads.
    public var showReward = true
    
    /// Whether to retry loading an ad after a failure.
    public var retryAfterFailed: Bool = true
    
    /// Whether to load a new ad after showing the previous one.
    public var loadAdAfterShowed: Bool = true
    
    /// Whether to reload native ads after they expire.
    public var loadNativeAfterExpire: Bool = true
    
    /// If set to true, ads will be loaded and displayed only in the specified orientation.
    public var forceOrientationAd: Bool = true
    
    /// Defines the preferred orientation for ad display (portrait or landscape).
    public var orientation: ALDeviceOrientation = .portrait
    
    /// Enables or disables debug logging for ad operations.
    public var logDebug: Bool = true
}
