//
//  BannerAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
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
    
    private weak var currentContainer: UIView?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
    
}

extension BannerAdManager {
    //Check condition to load Ad
    private func getAdUnitId() -> String? {
        guard configs.enableAds else {
            AdLog("BannerAd is not enabled")
            return nil
        }
        
        let adUnitId: String? = self.adUnitId ?? ALMHelper.shared.adUnits.bannerAdUnitId
        
        guard let adId = adUnitId, adId.notNil else {
            AdLog("BannerAd adUnitId is nil")
            return nil
        }
        
        return adId
    }
    
    public func loadBannerAd(
        parent view: UIView,
        placement: String? = nil,
        shimmerColor: UIColor = .lightGray,
        delegate: MAAdViewAdDelegate? = nil,
        revenueDelegate: MAAdRevenueDelegate? = nil,
        almDelegate: ALMHelperDelegate? = nil,
        reuse: Bool = false
    ) {
        guard let adId = getAdUnitId() else {
            return
        }
        
        Queue.main {
            self.delegate = almDelegate ?? self.delegate
            
            if reuse {
                if self.adView == nil {
                    self.createShimmer(at: view, shimmerColor: shimmerColor)
                    
                    self.adView = MAAdView(adUnitIdentifier: adId)
                    self.adView?.delegate = delegate ?? self
                    self.adView?.revenueDelegate = revenueDelegate ?? self
                    self.adView?.backgroundColor = .clear
                    self.adView?.loadAd()
                } else {
                    self.removeShimmer()
                }
                
                guard let adView = self.adView else { return }
                
                if adView.superview !== view {
                    adView.removeFromSuperview()
                    adView >>> view >>> {
                        $0.snp.makeConstraints { $0.edges.equalToSuperview() }
                        $0.placement = placement
                    }
                }
                
                self.currentContainer = view
                AdLog("Bannerview reuse attached")
                
            } else {
                self.createShimmer(at: view, shimmerColor: shimmerColor)
                
                self.adView = MAAdView(adUnitIdentifier: adId)
                guard let adView = self.adView else { return }
                
                adView >>> view >>> {
                    $0.snp.makeConstraints { $0.edges.equalToSuperview() }
                    $0.delegate = delegate ?? self
                    $0.revenueDelegate = revenueDelegate ?? self
                    $0.backgroundColor = .clear
                    $0.loadAd()
                    $0.placement = placement
                }
                
                self.currentContainer = view
                AdLog("Bannerview loadAd is called (non-reuse)")
            }
        }
    }
    
    
    public func reset() {
        Queue.main {
            self.adView?.removeFromSuperview()
            self.currentContainer = nil
            self.removeShimmer()
        }
    }
    
    public func reload() {
        Queue.main {
            self.adView?.loadAd()
        }
    }
    
    private func createShimmer(at view: UIView,
                               shimmerColor: UIColor) {
        self.shimmerView?.removeFromSuperview()
        self.shimmerView = UIView()
        
        if let shimmerView = self.shimmerView {
            shimmerView >>> view >>> {
                $0.snp.makeConstraints { $0.edges.equalToSuperview() }
                $0.isSkeletonable = true
            }
            
            shimmerView.layoutIfNeeded()
            Queue.main {
                shimmerView.startSkeletonAnimation()
                shimmerView.showAnimatedGradientSkeleton(
                    usingGradient: SkeletonGradient(baseColor: shimmerColor)
                )
            }
        }
    }
    
    private func removeShimmer() {
        if let shimmerView = self.shimmerView {
            shimmerView.stopSkeletonAnimation()
            shimmerView.removeFromSuperview()
        }
        self.shimmerView = nil
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
        AdLog("Bannerview delegate: didLoad at placement: \(ad.placement ?? "")")
        self.delegate?.didLoad(ad)
        self.removeShimmer()
    }
    
    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Bannerview delegate: didFailToLoadAd")
        delegate?.didFailToLoadAd(
            forAdUnitIdentifier: adUnitIdentifier, withError: error)
        if self.configs.removeShimmerOnFail {
            self.removeShimmer()
        }
    }
    
    public func didDisplay(_ ad: MAAd) {
        AdLog("Bannerview delegate: didDisplay")
        delegate?.didDisplay(ad)
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
