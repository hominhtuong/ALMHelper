//
//  ViewController.swift
//  Example
//
//  Created by Mitu Ultra on 14/3/25.
//

import ALMHelper
import MiTuKit
import AppLovinSDK

class ViewController: UIViewController {

    //Variables
    let showAdButton = UIButton()
    let bannerView = UIView()
    private var bannerAdManager: BannerAdManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        ALMHelper.shared.loadLandscapeInterstitial()
        setupView()
    }

    func setupView() {
        bannerAdManager = BannerAdManager()
        bannerAdManager.delegate = self
        
        bannerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(botSafe)
                $0.height.equalTo(50)
            }
            $0.attachBanner(bannerAdManager,
                            placement: "MainBanner")
        }

        showAdButton >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(120)
                $0.height.equalTo(45)
            }
            $0.backgroundColor = .random
            $0.layer.cornerRadius = 8
            $0.setTitle("Show Ad", for: .normal)
            $0.handle {
                ALMHelper.shared.showInterstitial()
//                let random = Int.random(in: 0..<3)
//                switch random {
//                case 0:
//                    printDebug("show RewardAd")
//                    ALMHelper.shared.showRewardAd(placement: "home_view_controller") { adState in
//                        if adState.isReward {
//                            printDebug("Reward received: \(adState.rewardAmount)")
//                            return
//                        }
//                        switch adState {
//                        case .failed:
//                            printDebug("ad failed")
//                            break
//                        case .hidden:
//                            printDebug("app hidden")
//                            break
//                        case .notReady:
//                            printDebug("ad not ready")
//                            break
//                        case .showed:
//                            printDebug("ad did display")
//                            break
//                        default:
//                            break
//                        }
//                    }
//                    break
//                case 1:
//                    printDebug("show Interstitial")
//                    ALMHelper.shared.showInterstitial { adState in
//
//                    }
//                    break
//                case 2:
//                    printDebug("show OpenAd")
//                    ALMHelper.shared.showOpenAds()
//                    break
//                default:
//                    break
//                }

            }
        }
    }
}

extension ViewController: ALMHelperDelegate {
    func didLoad(_ ad: MAAd) {
        printDebug("ad: \(ad.adUnitIdentifier) didload")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        printDebug("ad: \(adUnitIdentifier) didFailToLoadAd, withError: \(error.description)")
    }
    
    func didPayRevenue(for ad: MAAd) {
        printDebug("ad: \(ad.adUnitIdentifier) didPayRevenue")
    }
    
    func interstitialAdShowCalled(for adUnitIdentifier: String, placement: String) {
        printDebug("Add tracking: \(adUnitIdentifier) show called at \(placement)")
    }
    
    func showInterstitialAdSuccess(_ ad: MAAd, placement: String) {
        printDebug("Add tracking: \(ad.adUnitIdentifier) show success at \(placement)")
    }
    
    func showInterstitialAdClick(_ ad: MAAd, placement: String) {
        printDebug("Add tracking: \(ad.adUnitIdentifier) show click at \(placement)")
    }
}
