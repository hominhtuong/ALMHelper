//
//  InterstitialLandscapeManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//


import AppLovinSDK
import MiTuKit

public class InterstitialLandscapeManager: ALMBaseAd {
    public override init(adUnitId: String) {
        guard !adUnitId.isEmpty else {
            fatalError("adUnitId cannot be empty.")
        }
        
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitId)
        
        super.init(adUnitId: adUnitId)
    }
    
    public override var isAdReady: Bool {
        return interstitialAd.isReady
    }
    
    private let interstitialAd: MAInterstitialAd

}

extension InterstitialLandscapeManager {
    public override func loadAd() {
        if isAdReady {
            AdLog("Interstitial Landscape isReady")
            return
        }
        
        if configs.forceOrientationAd {
            let deviceOrientation = ALDeviceOrientation.current
            if deviceOrientation != .landscape {
                AdLog("Interstitial Landscape load failed - Orientation Mismatch, orientation config is landscape, device: \(deviceOrientation)")
                return
            }
        }
        
        interstitialAd.delegate = self
        interstitialAd.revenueDelegate = self

        delegate?.interstitialAdLoadCalled(for: adUnitId)
        interstitialAd.load()
        AdLog("Interstitial Landscape loadAd is called")
    }

    public override func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        if !isAdReady  {
            AdLog("Landscape Interstitial not ready")
            completion?(.notReady)
            loadAd()
            return
        }
        
        if configs.forceOrientationAd {
            let deviceOrientation = ALDeviceOrientation.current
            if deviceOrientation != .landscape {
                AdLog("Interstitial Landscape show failed - Orientation Mismatch, orientation config is landscape, device: \(deviceOrientation)")
                completion?(.notReady)
                return
            }
        }
        
        self.placement = placement
        delegate?.interstitialAdShowCalled(for: adUnitId, placement: placement)
        adCompletionHandle = completion
        
        if placement.isEmpty {
            AdLog("Interstitial Landscape show called")
            interstitialAd.show()
        } else {
            AdLog("Interstitial Landscape show called with placement: \(placement)")
            interstitialAd.show(forPlacement: placement)
        }
    }
}

extension InterstitialLandscapeManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didExpand")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didLoad")
        delegate?.didLoad(ad)
        retryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Interstitial Landscape delegate: didFailToLoadAd - error:\(error.description)")
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)

        if configs.retryAfterFailed {
            retryAttempt += 1
            let delaySec = pow(2.0, min(6.0, retryAttempt))

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
                self?.loadAd()
            }
        }
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showInterstitialAdSuccess(ad, placement: self.placement)
        
        adCompletionHandle?(.showed)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didHide")
        delegate?.didHide(ad)
        
        adCompletionHandle?(.hidden)
        adCompletionHandle = nil
        
        if configs.loadAdAfterShowed {
            self.loadAd()
        }
    }

    public func didClick(_ ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didClick")
        delegate?.didClick(ad)
        delegate?.showInterstitialAdClick(ad, placement: self.placement)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("Interstitial Landscape delegate: didFail to Display: \(error.description)")
        delegate?.didFail(toDisplay: ad, withError: error)
        
        adCompletionHandle?(.failed)
        
        if configs.loadAdAfterShowed {
            loadAd()
        }
    }
}


//MARK: MAAdRevenueDelegate
extension InterstitialLandscapeManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("Interstitial Landscape delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)

    }
}
