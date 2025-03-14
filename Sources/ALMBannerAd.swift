//
//  BannerAdManager.swift
//  ALMHelper
//
//  Created by Admin on 11/3/25.
//

import AppLovinSDK
import MiTuKit
import SkeletonView

public class BannerAdManager: NSObject {
    public init(adUnitId: String? = nil) {
        self.adUnitId = adUnitId
    }

    public var delegate: ALMHelperDelegate?
    
    private var adUnitId: String?
    private var adView: MAAdView?
    private var shimmerView: UIView?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }

}

public extension BannerAdManager {
    func loadBannerAd(parent view: UIView, shimmerColor: UIColor = .lightGray, delegate: MAAdViewAdDelegate? = nil, revenueDelegate: MAAdRevenueDelegate? = nil, almDelegate: ALMHelperDelegate? = nil) {
        guard configs.enableAds else {
            AdLog("BannerAd is not enabled")
            return
        }
        
        let adId: String? = self.adUnitId ?? ALMHelper.shared.adUnits.bannerAdUnitId
        guard let adId = adId else {
            AdLog("BannerAd adUnitId is nil")
            return
        }
        
        Queue.main {
            if let delegate = almDelegate {
                self.delegate = delegate
            }
            
            self.shimmerView = UIView()
            self.shimmerView! >>> view >>> {
                $0.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                $0.isSkeletonable = true
                $0.startSkeletonAnimation()
                $0.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: shimmerColor))
            }
            
            self.adView = MAAdView(adUnitIdentifier: adId)
            guard let adView = self.adView else {return}
            
            adView >>> view >>> {
                $0.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                $0.delegate = delegate ?? self
                $0.revenueDelegate = revenueDelegate ?? self
                $0.backgroundColor = .clear
                $0.loadAd()
            }
            
            AdLog("Bannerview loadAd is called")
        }
    }
}

//MARK: - Delegate
extension BannerAdManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        AdLog("Bannerview delegate: didHide")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("Bannerview delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("Bannerview delegate: didLoad")
        delegate?.didLoad(ad)
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Bannerview delegate: didFailToLoadAd")
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("Bannerview delegate: didDisplay")
        delegate?.didDisplay(ad)
        
        if let shimmerView = self.shimmerView {
            shimmerView.stopSkeletonAnimation()
            shimmerView.isHidden = true
        }
        
    }

    public func didHide(_ ad: MAAd) {
        AdLog("Bannerview delegate: didHide")
        delegate?.didHide(ad)
    }

    public func didClick(_ ad: MAAd) {
        AdLog("Bannerview delegate: didClick")
        delegate?.didClick(ad)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("Bannerview delegate: didFail to display - error: \(error)")
        delegate?.didFail(toDisplay: ad, withError: error)
    }
}

//MARK: MAAdRevenueDelegate
extension BannerAdManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("Bannerview delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)
    }
}

