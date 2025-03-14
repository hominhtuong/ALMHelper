//
//  ALMHelperDelegate.swift
//  ALMHelper
//
//  Created by Admin on 11/3/25.
//

import AppLovinSDK

public protocol ALMHelperDelegate {
    
    func interstitialAdShowCalled(for adUnitIdentifier: String)
    func rewardAdShowCalled(for adUnitIdentifier: String)
    func openAdShowCalled(for adUnitIdentifier: String)
    
    func didPayRevenue(for ad: MAAd)
    func didExpand(_ ad: MAAd)
    func didCollapse(_ ad: MAAd)
    func didLoad(_ ad: MAAd)
    func didDisplay(_ ad: MAAd)
    func didHide(_ ad: MAAd)
    func didClick(_ ad: MAAd)
    func didFail(toDisplay ad: MAAd, withError error: MAError)
    func didRewardUser(for ad: MAAd, with reward: MAReward)
    func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    )
    
    func didExpireNativeAd(_ ad: MAAd)
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd)
    func didFailToLoadNativeAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    )
}

public extension ALMHelperDelegate {
    func interstitialAdShowCalled(for adUnitIdentifier: String) {}
    func rewardAdShowCalled(for adUnitIdentifier: String) {}
    func openAdShowCalled(for adUnitIdentifier: String) {}
    
    func didPayRevenue(for ad: MAAd) {}
    func didExpand(_ ad: MAAd) {}
    func didCollapse(_ ad: MAAd) {}
    func didLoad(_ ad: MAAd) {}
    func didDisplay(_ ad: MAAd) {}
    func didHide(_ ad: MAAd) {}
    func didClick(_ ad: MAAd) {}
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    func didRewardUser(for ad: MAAd, with reward: MAReward) {}
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didExpireNativeAd(_ ad: MAAd) {}
    func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd) {}
    func didFailToLoadNativeAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {}
}
