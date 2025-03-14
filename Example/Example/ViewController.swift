//
//  ViewController.swift
//  Example
//
//  Created by Admin on 14/3/25.
//

import MiTuKit
import ALMHelper

class ViewController: UIViewController {
    
    //Variables
    let showAdButton = UIButton()
    let bannerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        
        setupAd()
        setupView()
    }
    
    func setupAd() {
        Task {
            let adUnits = ALMUnits(
                openAdUnitId: Configurations.AdUnits.openAdUnitId,
                bannerAdUnitId: Configurations.AdUnits.bannerAdUnitId,
                interstitialAdUnitId: Configurations.AdUnits.interstitialAdUnitId,
                rewardAdUnitId: Configurations.AdUnits.rewardAdUnitId,
                nativeAdUnitId: Configurations.AdUnits.nativeAdUnitId
            )
            await ALMHelper.shared.setup(sdkKey: Configurations.applovinSDKKey, units: adUnits)
            ALMHelper.shared.loadInterstitial()
            
            //...
        }
    }
    
    func setupView() {
        bannerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(botSafe)
                $0.height.equalTo(50)
            }
            $0.attachBanner(backgroundColor: .random)
        }
        
        showAdButton >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(100)
                $0.height.equalTo(30)
            }
            $0.layer.cornerRadius = 15
            $0.setTitle("Show Ad", for: .normal)
            $0.handle {
                let random = Int.random(in: 0..<3)
                switch random {
                case 0:
                    printDebug("showRewardAd")
                    ALMHelper.shared.showRewardAd()
                    break
                case 1:
                    printDebug("showInterstitial")
                    ALMHelper.shared.showInterstitial { state in
                        
                    }
                    break
                case 2:
                    printDebug("showOpenAds")
                    ALMHelper.shared.showOpenAds()
                    break
                default:
                    printDebug("attachBanner")
                    self.bannerView.reloadBanner(backgroundColor: .random)
                    break
                }
                
            }
        }
    }
}
