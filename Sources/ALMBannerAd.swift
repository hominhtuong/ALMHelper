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
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }

    private let adUnitId: String
    private var adView: MAAdView?
    private let shimmerView = UIView()
    
    var delegate: ALMHelperDelegate?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }

}

public extension BannerAdManager {
    func loadBannerAd(parent view: UIView, backgroundColor: UIColor = .white) {
        guard configs.enableAds else {
            AdLog("Bannerview is not enabled")
            return
        }
        guard adUnitId.notNil else {
            AdLog("Bannerview adUnitId is nil")
            return
        }
        Queue.main {
            self.shimmerView >>> view >>> {
                $0.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                $0.isSkeletonable = true
                $0.startSkeletonAnimation()
                $0.showAnimatedGradientSkeleton()
            }
            
            self.adView = MAAdView(adUnitIdentifier: self.adUnitId)
            guard let adView = self.adView else {return}
            
            adView >>> view >>> {
                $0.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                $0.delegate = self
                $0.revenueDelegate = self
                $0.backgroundColor = backgroundColor
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
        
        self.shimmerView.stopSkeletonAnimation()
        self.shimmerView.isHidden = true
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

