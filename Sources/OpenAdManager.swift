//
//  OpenAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import AppLovinSDK

public class OpenAdManager: NSObject {
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init()
        
        if adUnitId.notNil {
            self.appOpenAd = MAAppOpenAd(
                adUnitIdentifier: adUnitId)
        }
    }

    private var placement: String = ""
    private let adUnitId: String
    private var appOpenAd: MAAppOpenAd?

    private var openAdRetryAttempt = 0.0
    private var completionShowOpenAds: ((AdDisplayState) -> Void)?

    var delegate: ALMHelperDelegate?

    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
}

extension OpenAdManager {
    public func loadAd() {
        guard let appOpenAd = self.appOpenAd else {
            AdLog("OpenAd has not been initialized.")
            return
        }

        if appOpenAd.isReady {
            AdLog("OpenAd isReady")
            return
        }

        appOpenAd.delegate = self
        appOpenAd.revenueDelegate = self

        delegate?.openAdLoadCalled(for: adUnitId)
        appOpenAd.load()
        AdLog("OpenAd loadAd is called")
    }

    public func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        guard let appOpenAd = self.appOpenAd else {
            AdLog("OpenAd has not been initialized.")
            completion?(.notReady)
            return
        }

        if !appOpenAd.isReady {
            AdLog("OpenAd not ready")
            completion?(.notReady)
            return
        }

        delegate?.openAdShowCalled(for: self.adUnitId, placement: placement)
        completionShowOpenAds = completion
        appOpenAd.show()
        AdLog("OpenAd show called")
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

        openAdRetryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("OpenAd delegate: didFailToLoadAd - error:\(error.description)")
        delegate?.didFailToLoadAd(
            forAdUnitIdentifier: adUnitIdentifier, withError: error)

        if configs.retryAfterFailed {
            openAdRetryAttempt += 1
            let delaySec = pow(2.0, min(6.0, openAdRetryAttempt))

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                self.loadAd()
            }
        }
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("OpenAd delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showOpenAdSuccess(ad, placement: self.placement)

        completionShowOpenAds?(.showed)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("OpenAd delegate: didHide")
        delegate?.didHide(ad)

        completionShowOpenAds?(.hidden)

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

        completionShowOpenAds?(.failed)

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
