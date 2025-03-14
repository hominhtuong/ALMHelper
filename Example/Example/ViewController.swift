//
//  ViewController.swift
//  Example
//
//  Created by Admin on 14/3/25.
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
            $0.attachBanner(bannerAdManager)
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
                    break
                }

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
}
