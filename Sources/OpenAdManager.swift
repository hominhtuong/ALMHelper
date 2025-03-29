//
//  OpenAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import AppLovinSDK
import MiTuKit

public class OpenAdManager: ALMBaseAd {
    public override init(adUnitId: String) {
        guard !adUnitId.isEmpty else {
            fatalError("adUnitId cannot be empty.")
        }
        self.appOpenAd = MAAppOpenAd(adUnitIdentifier: adUnitId)
        
        super.init(adUnitId: adUnitId)
    }
    
    public override var isAdReady: Bool {
        return appOpenAd.isReady
    }
    
    private let appOpenAd: MAAppOpenAd
}

extension OpenAdManager {
    public override func loadAd() {
        if isAdReady {
            AdLog("OpenAd isReady")
            return
        }
        
        if configs.forceOrientationAd {
            let deviceOrientation = ALDeviceOrientation.current
            if configs.orientation != deviceOrientation {
                AdLog("OpenAd load failed - Orientation Mismatch, orientation config: \(configs.orientation), device: \(deviceOrientation)")
                return
            }
        }

        appOpenAd.delegate = self
        appOpenAd.revenueDelegate = self

        delegate?.openAdLoadCalled(for: adUnitId)
        appOpenAd.load()
        AdLog("OpenAd loadAd is called")
    }

    public override func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        if !isAdReady {
            AdLog("OpenAd not ready")
            completion?(.notReady)
            return
        }

        if configs.forceOrientationAd {
            let deviceOrientation = ALDeviceOrientation.current
            if configs.orientation != deviceOrientation {
                AdLog("OpenAd show failed - Orientation Mismatch, orientation config: \(configs.orientation), device: \(deviceOrientation)")
                return
            }
        }
        
        delegate?.openAdShowCalled(for: adUnitId, placement: placement)
        adCompletionHandle = completion
        
        if placement.isEmpty {
            AdLog("OpenAd show called")
            appOpenAd.show()
        } else {
            AdLog("OpenAd show called with placement: \(placement)")
            appOpenAd.show(forPlacement: placement)
        }
    }
}

extension OpenAdManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        AdLog("OpenAd delegate: didExpand")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("OpenAd delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("OpenAd delegate: didLoad")
        delegate?.didLoad(ad)

        retryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("OpenAd delegate: didFailToLoadAd - error:\(error.description)")
        delegate?.didFailToLoadAd(
            forAdUnitIdentifier: adUnitIdentifier, withError: error)

        if configs.retryAfterFailed {
            retryAttempt += 1
            let delaySec = pow(2.0, min(6.0, retryAttempt))

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
                self?.loadAd()
            }
        }
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("OpenAd delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showOpenAdSuccess(ad, placement: self.placement)

        adCompletionHandle?(.showed)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("OpenAd delegate: didHide")
        delegate?.didHide(ad)

        adCompletionHandle?(.hidden)
        adCompletionHandle = nil

        if configs.loadAdAfterShowed {
            loadAd()
        }
    }

    public func didClick(_ ad: MAAd) {
        AdLog("OpenAd delegate: didClick")
        delegate?.didClick(ad)
        delegate?.showOpenAdClick(ad, placement: self.placement)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("OpenAd delegate: didFail, error: \(error.description)")
        delegate?.didFail(toDisplay: ad, withError: error)

        adCompletionHandle?(.failed)
        adCompletionHandle = nil

        if configs.loadAdAfterShowed {
            loadAd()
        }
    }
}

//MARK: MAAdRevenueDelegate
extension OpenAdManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("OpenAd delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)
    }

}
