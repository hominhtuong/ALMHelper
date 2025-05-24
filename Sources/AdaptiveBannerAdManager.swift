//
//  AdaptiveBannerAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import AppLovinSDK
import MiTuKit
import SkeletonView

public class AdaptiveBannerAdManager: NSObject {
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

extension AdaptiveBannerAdManager {
    public func loadAdaptiveBannerAd(
        parent view: UIView,
        placement: String? = nil,
        shimmerColor: UIColor = .lightGray,
        delegate: MAAdViewAdDelegate? = nil,
        adViewConfigs: MAAdViewConfiguration? = nil,
        revenueDelegate: MAAdRevenueDelegate? = nil,
        almDelegate: ALMHelperDelegate? = nil
    ) {
        guard configs.enableAds else {
            AdLog("Adaptive BannerAd is not enabled")
            return
        }

        let adUnitId: String? = self.adUnitId ?? ALMHelper.shared.adUnits.bannerAdUnitId
        
        guard let adId = adUnitId, adId.notNil else {
            AdLog("Adaptive BannerAd adUnitId is nil")
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
                $0.showAnimatedGradientSkeleton(
                    usingGradient: SkeletonGradient(baseColor: shimmerColor))
            }

            let adConfigs = adViewConfigs ?? MAAdViewConfiguration { builder in
                builder.adaptiveType = .anchored
            }
            
            self.adView = MAAdView(adUnitIdentifier: adId, configuration: adConfigs)
            guard let adView = self.adView else { return }

            adView >>> view >>> {
                $0.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                $0.delegate = delegate ?? self
                $0.revenueDelegate = revenueDelegate ?? self
                $0.backgroundColor = .clear
                $0.loadAd()
                $0.placement = placement
            }

            AdLog("Bannerview loadAd is called")
        }
    }
}

//MARK: - Delegate
extension AdaptiveBannerAdManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didHide")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didLoad")
        delegate?.didLoad(ad)

        if let shimmerView = self.shimmerView {
            shimmerView.stopSkeletonAnimation()
            shimmerView.isHidden = true
        }
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Adaptive Bannerview delegate: didFailToLoadAd")
        delegate?.didFailToLoadAd(
            forAdUnitIdentifier: adUnitIdentifier, withError: error)
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didDisplay")
        delegate?.didDisplay(ad)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didHide")
        delegate?.didHide(ad)
    }

    public func didClick(_ ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didClick")
        delegate?.didClick(ad)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("Adaptive Bannerview delegate: didFail to display - error: \(error)")
        delegate?.didFail(toDisplay: ad, withError: error)
    }
}

//MARK: MAAdRevenueDelegate
extension AdaptiveBannerAdManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("Adaptive Bannerview delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)
    }
}
