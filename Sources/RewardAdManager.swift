//
//  RewardAdManager.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//


import AppLovinSDK
import MiTuKit

public class RewardAdManager: ALMBaseAd {
    public override init(adUnitId: String) {
        guard !adUnitId.isEmpty else {
            fatalError("adUnitId cannot be empty.")
        }
        self.rewardAd = MARewardedAd.shared(withAdUnitIdentifier: adUnitId)
        
        super.init(adUnitId: adUnitId)
    }
    
    public override var isAdReady: Bool {
        return rewardAd.isReady
    }
    
    private let rewardAd: MARewardedAd
}

extension RewardAdManager {
    public override func loadAd() {
        if isAdReady {
            AdLog("RewardAd isReady")
            return
        }
        
        rewardAd.delegate = self
        rewardAd.revenueDelegate = self

        delegate?.rewardAdLoadCalled(for: adUnitId)
        rewardAd.load()
        AdLog("RewardAd loadAd is called")
    }

    public override func showAds(placement: String = "", _ completion: ((AdDisplayState) -> Void)? = nil) {
        if !isAdReady  {
            AdLog("RewardAd not ready")
            completion?(.notReady)
            return
        }
        
        delegate?.rewardAdShowCalled(for: self.adUnitId, placement: self.placement)
        adCompletionHandle = completion
        
        if placement.isEmpty {
            AdLog("RewardAd show called")
            rewardAd.show()
        } else {
            AdLog("RewardAd show called with placement: \(placement)")
            rewardAd.show(forPlacement: placement)
        }
    }
}

extension RewardAdManager: MARewardedAdDelegate {
    public func didRewardUser(for ad: MAAd, with reward: MAReward) {
        AdLog("RewardAd delegate: didRewardUser, reward: \(reward.amount)")
        delegate?.didRewardUser(for: ad, with: reward)
        
        adCompletionHandle?(.didReward(reward.amount))
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
        
        retryAttempt = 0
    }

    public func didFailToLoadAd(
        forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError
    ) {
        AdLog("RewardAd delegate: didFailToLoadAd - error:\(error.description)")
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
        AdLog("RewardAd delegate: didDisplay")
        delegate?.didDisplay(ad)
        delegate?.showRewardAdSuccess(ad, placement: self.placement)
    }

    public func didHide(_ ad: MAAd) {
        AdLog("RewardAd delegate: didHide")
        delegate?.didHide(ad)
        
        adCompletionHandle?(.hidden)
        adCompletionHandle = nil
        
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
        
        adCompletionHandle?(.failed)
        adCompletionHandle = nil
        
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
