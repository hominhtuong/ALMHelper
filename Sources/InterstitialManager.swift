//
//  InterstitialManager.swift
//  ALMHelper
//
//  Created by Admin on 11/3/25.
//


import AppLovinSDK

public class InterstitialManager: NSObject {
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        self.interstitialAd = MAInterstitialAd(
            adUnitIdentifier: adUnitId)
    }
    
    private let adUnitId: String
    private let interstitialAd: MAInterstitialAd?
    private var interRetryAttempt = 0.0
    private var completionShowInterstitial: ((AdDisplayState) -> Void)?
    
    var delegate: ALMHelperDelegate?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
}

public extension InterstitialManager {
    func loadAd() {
        guard let interstitialAd = self.interstitialAd else {
            AdLog("Interstitial has not been initialized.")
            return
        }
        
        if interstitialAd.isReady {
            AdLog("Interstitial isReady")
            return
        }
        
        interstitialAd.delegate = self
        interstitialAd.revenueDelegate = self

        delegate?.interstitialAdLoadCalled(for: adUnitId)
        interstitialAd.load()
        AdLog("Interstitial loadAd is called")
    }

    func showAds(_ completion: ((AdDisplayState) -> Void)? = nil) {
        guard let interstitialAd = self.interstitialAd else {
            AdLog("Interstitial has not been initialized.")
            completion?(.notReady)
            return
        }
        
        if !interstitialAd.isReady  {
            AdLog("Interstitial not ready")
            completion?(.notReady)
            return
        }
        
        delegate?.interstitialAdShowCalled(for: adUnitId)
        completionShowInterstitial = completion
        interstitialAd.show()
        AdLog("Interstitial show called")
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
        interRetryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("Interstitial delegate: didFailToLoadAd - error:\(error.description)")
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)

        if configs.retryAfterFailed {
            interRetryAttempt += 1
            let delaySec = pow(2.0, min(6.0, interRetryAttempt))

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                self.loadAd()
            }
        }
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("Interstitial delegate: didDisplay")
        delegate?.didDisplay(ad)
        
        completionShowInterstitial?(.showed)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("Interstitial delegate: didHide")
        delegate?.didHide(ad)
        
        completionShowInterstitial?(.hidden)
        
        if configs.loadAdAfterShowed {
            self.loadAd()
        }
    }

    public func didClick(_ ad: MAAd) {
        AdLog("Interstitial delegate: didClick")
        delegate?.didClick(ad)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("Interstitial delegate: didFail to Display: \(error.description)")
        delegate?.didFail(toDisplay: ad, withError: error)
        
        completionShowInterstitial?(.failed)
        
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
