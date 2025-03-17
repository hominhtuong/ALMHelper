//
//  RewardAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//


import AppLovinSDK

public class RewardAdManager: NSObject {
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init()
        
        if adUnitId.notNil {
            self.rewardAd = MARewardedAd.shared(withAdUnitIdentifier: adUnitId)
        }
    }
    
    private var placement: String = ""
    private let adUnitId: String
    private var rewardAd: MARewardedAd?
    private var rewardRetryAttempt = 0.0
    private var completionShowRewardAd: ((AdDisplayState) -> Void)?
    
    var delegate: ALMHelperDelegate?
    
    private var configs: ALMConfiguration {
        return ALMHelper.shared.configs
    }
}

public extension RewardAdManager {
    func loadAd() {
        guard let rewardAd = self.rewardAd else {
            AdLog("RewardAd has not been initialized.")
            return
        }
        
        if rewardAd.isReady {
            AdLog("RewardAd isReady")
            return
        }
        
        rewardAd.delegate = self
        rewardAd.revenueDelegate = self

        delegate?.rewardAdLoadCalled(for: adUnitId)
        rewardAd.load()
        AdLog("RewardAd loadAd is called")
    }

    func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        guard let rewardAd = self.rewardAd else {
            AdLog("RewardAd has not been initialized.")
            completion?(.notReady)
            return
        }
        
        if !rewardAd.isReady  {
            AdLog("RewardAd not ready")
            completion?(.notReady)
            return
        }
        
        delegate?.rewardAdShowCalled(for: self.adUnitId, placement: self.placement)
        completionShowRewardAd = completion
        
        if placement.notNil {
            rewardAd.show(forPlacement: placement)
        } else {
            rewardAd.show()
        }
        AdLog("RewardAd show called")
    }
}

extension RewardAdManager: MARewardedAdDelegate {
    public func didRewardUser(for ad: MAAd, with reward: MAReward) {
        AdLog("RewardAd delegate: didRewardUser, reward: \(reward.amount)")
        delegate?.didRewardUser(for: ad, with: reward)
        
        completionShowRewardAd?(.didReward(reward.amount))
    }
    
    public func didExpand(_ ad: MAAd) {
        AdLog("RewardAd delegate: didExpand")
        delegate?.didExpand(ad)
    }

    public func didCollapse(_ ad: MAAd) {
        AdLog("RewardAd delegate: didCollapse")
        delegate?.didCollapse(ad)
    }

    public func didLoad(_ ad: MAAd) {
        AdLog("RewardAd delegate: didLoad")
        delegate?.didLoad(ad)
        
        rewardRetryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("RewardAd delegate: didFailToLoadAd - error:\(error.description)")
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)

        if configs.retryAfterFailed {
            rewardRetryAttempt += 1
            let delaySec = pow(2.0, min(6.0, rewardRetryAttempt))

            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                self.loadAd()
            }
        }
    }

    public func didDisplay(_ ad: MAAd) {
        AdLog("RewardAd delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showRewardAdSuccess(ad, placement: self.placement)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("RewardAd delegate: didHide")
        delegate?.didHide(ad)
        
        completionShowRewardAd?(.hidden)
        
        if configs.loadAdAfterShowed {
            loadAd()
        }
    }

    public func didClick(_ ad: MAAd) {
        AdLog("RewardAd delegate: didClick")
        delegate?.didClick(ad)
        delegate?.showRewardAdClick(ad, placement: self.placement)
    }

    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AdLog("RewardAd delegate: didFail, error: \(error.description)")
        delegate?.didFail(toDisplay: ad, withError: error)
        
        completionShowRewardAd?(.failed)
        
        if configs.loadAdAfterShowed {
            loadAd()
        }
    }
}


//MARK: MAAdRevenueDelegate
extension RewardAdManager: MAAdRevenueDelegate {
    public func didPayRevenue(for ad: MAAd) {
        AdLog("RewardAd delegate: didPayRevenue")
        delegate?.didPayRevenue(for: ad)
    }

}
