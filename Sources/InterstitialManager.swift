//
//  InterstitialManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//


import AppLovinSDK
import MiTuKit

public class InterstitialManager: ALMBaseAd {
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

extension InterstitialManager {
    public override func loadAd() {
        if isAdReady {
            AdLog("Interstitial isReady")
            return
        }
        
        if configs.forceOrientationAd {
            let deviceOrientation = UIDevice.current.orientation
            if configs.orientation != deviceOrientation {
                AdLog("Interstitial load failed - Orientation Mismatch, orientation config: \(configs.orientation), device: \(deviceOrientation)")
                return
            }
        }
        
        interstitialAd.delegate = self
        interstitialAd.revenueDelegate = self

        delegate?.interstitialAdLoadCalled(for: adUnitId)
        interstitialAd.load()
        AdLog("Interstitial loadAd is called")
    }

    public override func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        if !isAdReady  {
            AdLog("Interstitial not ready")
            completion?(.notReady)
            return
        }
        
        if configs.forceOrientationAd {
            let deviceOrientation = UIDevice.current.orientation
            if configs.orientation != deviceOrientation {
                AdLog("Interstitial show failed - Orientation Mismatch, orientation config: \(configs.orientation), device: \(deviceOrientation)")
                completion?(.notReady)
                return
            }
        }
        
        self.placement = placement
        delegate?.interstitialAdShowCalled(for: adUnitId, placement: placement)
        adCompletionHandle = completion
        
        if placement.isEmpty {
            AdLog("Interstitial show called")
            interstitialAd.show()
        } else {
            AdLog("Interstitial show called with placement: \(placement)")
            interstitialAd.show(forPlacement: placement)
        }
    }
}

extension InterstitialManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        AdLog("Interstitial delegate: didExpand")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("Interstitial delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("Interstitial delegate: didLoad")
        delegate?.didLoad(ad)
        retryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Interstitial delegate: didFailToLoadAd - error:\(error.description)")
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
        AdLog("Interstitial delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showInterstitialAdSuccess(ad, placement: self.placement)
        
        adCompletionHandle?(.showed)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("Interstitial delegate: didHide")
        delegate?.didHide(ad)
        
        adCompletionHandle?(.hidden)
        adCompletionHandle = nil
        
        if configs.loadAdAfterShowed {
            self.loadAd()
        }
    }

    public func didClick(_ ad: MAAd) {
        AdLog("Interstitial delegate: didClick")
        delegate?.didClick(ad)
        delegate?.showInterstitialAdClick(ad, placement: self.placement)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("Interstitial delegate: didFail to Display: \(error.description)")
        delegate?.didFail(toDisplay: ad, withError: error)
        
        adCompletionHandle?(.failed)
        
        if configs.loadAdAfterShowed {
            loadAd()
        }
    }
}


//MARK: MAAdRevenueDelegate
extension InterstitialManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("Interstitial delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)

    }
}
