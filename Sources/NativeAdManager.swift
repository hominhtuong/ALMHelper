//
//  NativeAdManager.swift
//  ALMHelper
//
//  Created by Admin on 14/3/25.
//

import AppLovinSDK

public class NativeAdManager: NSObject {
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        self.nativeAdLoader = MANativeAdLoader(adUnitIdentifier: adUnitId)
    }
    
    private let adUnitId: String
    private let nativeAdLoader: MANativeAdLoader?
    private var nativeAd: MAAd?
    private var nativeAdView: UIView?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
    
    var delegate: ALMHelperDelegate?
}

public extension NativeAdManager {
    func loadAd() {
        if let currentNativeAd = nativeAd {
            nativeAdLoader?.destroy(currentNativeAd)
        }
        
        guard let nativeAdLoader = self.nativeAdLoader else {
            return
        }
        
        nativeAdLoader.nativeAdDelegate = self
        nativeAdLoader.revenueDelegate = self
        nativeAdLoader.loadAd()
    }
}

extension NativeAdManager: MANativeAdDelegate, MAAdRevenueDelegate {
    public func didLoadNativeAd(_ maxNativeAdView: MANativeAdView?, for ad: MAAd) {
        self.nativeAdView = maxNativeAdView
        self.nativeAd = ad
        self.delegate?.didLoadNativeAd(maxNativeAdView, for: ad)
        AdLog("NativeAd delegate: didLoadNativeAd")
    }

    public func didFailToLoadNativeAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("NativeAd delegate: didFailToLoadNativeAd - error: \(error.description)")
        self.delegate?.didFailToLoadNativeAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
    }

    public func didClickNativeAd(_ ad: MAAd) {
        AdLog("NativeAd delegate: didClickNativeAd")
        self.delegate?.didClick(ad)
    }

    public func didExpireNativeAd(_ ad: MAAd) {
        AdLog("NativeAd delegate: didClickNativeAd")
        self.delegate?.didExpireNativeAd(ad)
        
        if configs.loadNativeAfterExpire {
            loadAd()
        }
    }

    public func didPayRevenue(for ad: MAAd) {
        AdLog("NativeAd delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)
    }
}
