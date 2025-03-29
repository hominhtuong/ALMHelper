# ALMHelper
[![Version](https://img.shields.io/cocoapods/v/ALMHelper.svg?style=flat)](https://cocoapods.org/pods/ALMHelper)
[![License](https://img.shields.io/cocoapods/l/ALMHelper.svg?style=flat)](https://cocoapods.org/pods/ALMHelper)
[![Platform](https://img.shields.io/cocoapods/p/ALMHelper.svg?style=flat)](https://cocoapods.org/pods/ALMHelper)

## About  
HI,  
ALMHelper is a powerful Swift library designed to simplify Applovin MAX ad management. It provides:

✅ Easy Ad Loading & Displaying – Load and show Interstitial, Rewarded, Banner, Native, and Open Ads with minimal setup.  
✅ Smart Delegation System – Improved delegate handling for cleaner and more maintainable code.  
✅ Ad Frequency Control – Avoid ad spam with built-in frequency capping and impression percentage logic.  
✅ GDPR & Privacy Compliance – Includes built-in tracking request and CMP handling.  
⚡ ALMHelper – The ultimate tool for maximizing your `Applovin MAX` ad revenue! 🚀  

## Installation with CocoaPods
To integrate ALMHelper into your Xcode project using CocoaPods, specify it in your `Podfile`

```ruby
target 'MyApp' do
  pod 'ALMHelper'
end
```

## Swift Package Manager
Once you have your Swift package set up, adding ALMHelper as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/hominhtuong/ALMHelper.git", .upToNextMajor(from: "1.0.9"))
]
```

## Example code:
##### The code would look like this:

```swift
import ALMHelper

class SplashViewController: UIViewController {
    func setupAd() {
        Task {
            let adUnits = ALAdUnits(
                openAdUnitId: AdUnits.openAdUnitId,
                bannerAdUnitId: AdUnits.bannerAdUnitId,
                interstitialAdUnitId: AdUnits.interstitialAdUnitId,
                rewardAdUnitId: AdUnits.rewardAdUnitId,
                nativeAdUnitId: AdUnits.nativeAdUnitId
            )
            await ALMHelper.shared.setup(sdkKey: applovinSDKKey, units: adUnits)
            
            //Load configs online then setup
            ALMHelper.shared.configs.enableAds = true
            ALMHelper.shared.configs.showInterstitial = true
            //...
            
            ALMHelper.shared.loadInterstitial()
            //...
        }
    }
}
    
```

##### Show Ads:

```swift
import ALMHelper

class ViewController: UIViewController {
    func nextScreen() {
        ALMHelper.shared.showInterstitial()
        self.navigationController?.pushViewController(NextScreen(), animated: true)
    }
    
    func showAdThenNextScreen() {
        ALMHelper.shared.showInterstitial { state in
            if state == .showed { return } 
            self.navigationController?.pushViewController(NextScreen(), animated: true)
        }
    }
    
    func showAdAndNextScreen() {
        ALMHelper.shared.showInterstitial { state in
            if state == .hidden { return } 
            self.navigationController?.pushViewController(NextScreen(), animated: false)
        }
    }
    
    func showAdWithTrackingPlace() {
        ALMHelper.shared.showRewardAd(placement: "home_view_controller") { adState in
            if adState.isReward {
                printDebug("Reward received: \(adState.rewardAmount)")
                return
            }
                        
            switch adState {
                case .failed:
                    printDebug("ad failed")
                    break
                case .hidden:
                    printDebug("app hidden")
                    break
                case .notReady:
                    printDebug("ad not ready")
                    break
                case .showed:
                    printDebug("ad did display")
                    break
                default:
                    break
                }
         }
    }
}
```

##### 🔥 Important!!!!
The `state` from the completion handler in a successful case will be called twice  
 `didDisplay` and `didHide` (`.showed and .hidden`).

You can navigate to another screen when `state == .showed` while the interstitial is being presented (without affecting the user experience) or after it is dismissed with `state == .hidden`.

##### Banner Ads:

```swift
import ALMHelper

class ViewController: UIViewController {
    func setupView() {
        let bannerView = UIView()
        bannerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(botSafe)
                $0.height.equalTo(50)
            }
            $0.attachBanner()
        }
    }
}
```

##### Ad Delegate:

```swift
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
```

## License
  ALMHelper is released under the MIT license. See [LICENSE](https://github.com/hominhtuong/ALMHelper/blob/main/LICENSE) for more details.  
<br>
My website: [Visit](https://mituultra.com/)
