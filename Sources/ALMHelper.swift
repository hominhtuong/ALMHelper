//
//  ALMHelper.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 11/3/25.
//

import AppLovinSDK
import MiTuKit

public class ALMHelper: NSObject {
    public static let shared = ALMHelper()

    public var configs: ALMConfiguration = ALMConfiguration()
    public var adUnits: ALMUnits = ALMUnits()

    //Interstitial
    private var interstitialLastTime: TimeInterval = 0

    public var interstitialManager: InterstitialManager?
    public var interstitialDelegate: ALMHelperDelegate? {
        get {
            return interstitialManager?.delegate
        }
        set {
            interstitialManager?.delegate = newValue
        }
    }

    public var interstitialLandscapeManager: InterstitialLandscapeManager?
    public var interstitialLandscapeDelegate: ALMHelperDelegate? {
        get {
            return interstitialManager?.delegate
        }
        set {
            interstitialManager?.delegate = newValue
        }
    }

    //OpenAd
    private var openAdLastTime: TimeInterval = 0

    public var openAdManager: OpenAdManager?
    public var openAdDelegate: ALMHelperDelegate? {
        get {
            return openAdManager?.delegate
        }
        set {
            openAdManager?.delegate = newValue
        }
    }

    //RewardAd
    private var rewardAdLastTime: TimeInterval = 0

    public var rewardManager: RewardAdManager?
    public var rewardAdDelegate: ALMHelperDelegate? {
        get {
            return rewardManager?.delegate
        }
        set {
            rewardManager?.delegate = newValue
        }
    }

    //NativeAd
    public var nativeAdManager: NativeAdManager?
    public var nativeAdDelegate: ALMHelperDelegate? {
        get {
            return nativeAdManager?.delegate
        }
        set {
            nativeAdManager?.delegate = newValue
        }
    }

    //BannerAd
    public var bannerAdManager: BannerAdManager?
    public var bannerAdDelegate: ALMHelperDelegate? {
        get {
            return bannerAdManager?.delegate
        }
        set {
            bannerAdManager?.delegate = newValue
        }
    }

}

//MARK: - Setup
extension ALMHelper {
    public func loadAndShowCMP() async -> String? {
        await withCheckedContinuation { continuation in
            let cmpService = ALSdk.shared().cmpService
            cmpService.showCMPForExistingUser { error in
                continuation.resume(returning: error?.cmpMessage)
            }
        }
    }
    public func requestTracking(from topVC: UIViewController? = nil) async
        -> Error?
    {
        return await GDPRManager.shared.requestTracking(
            from: topVC,
            testDeviceIdentifiers: []
        )
    }

    public func setupUnits(units: ALMUnits) async {
        adUnits = units

        if let openAdUnitId = units.openAdUnitId, openAdUnitId.notNil {
            self.openAdManager = OpenAdManager(
                adUnitId: openAdUnitId
            )
        }

        if let bannerAdUnitId = units.bannerAdUnitId, bannerAdUnitId.notNil {
            self.bannerAdManager = BannerAdManager(adUnitId: bannerAdUnitId)
        }

        if let interstitialAdUnitId = units.interstitialAdUnitId,
            interstitialAdUnitId.notNil
        {
            self.interstitialManager = InterstitialManager(
                adUnitId: interstitialAdUnitId
            )
        }

        if let rewardAdUnitId = units.rewardAdUnitId, rewardAdUnitId.notNil {
            self.rewardManager = RewardAdManager(
                adUnitId: rewardAdUnitId
            )
        }

        if let nativeAdUnitId = units.nativeAdUnitId, nativeAdUnitId.notNil {
            self.nativeAdManager = NativeAdManager(adUnitId: nativeAdUnitId)
        }

    }

    public func initAd(sdkKey: String) async {
        guard sdkKey.notNil else {
            AdLog("SDK key is nil")
            return
        }

        await withCheckedContinuation { continuation in
            let initConfig = ALSdkInitializationConfiguration(
                sdkKey: sdkKey
            ) { builder in

                builder.mediationProvider = ALMediationProviderMAX

                #if DEBUG
                    if let currentIDFV = UIDevice.current.identifierForVendor?
                        .uuidString
                    {
                        builder.testDeviceAdvertisingIdentifiers = [currentIDFV]
                    }
                #endif
            }

            ALSdk.shared().initialize(with: initConfig) { sdkConfig in
                continuation.resume()
            }
        }
    }

    public func updateSettings(
        privacyPolicyURL: String?,
        termsOfServiceURL: String?,
        debugUserGeography: Bool,
        isVerboseLoggingEnabled: Bool,
        showMediationDebugger: Bool,
        showCreativeDebugger: Bool
    ) async {
        let settings = ALSdk.shared().settings

        if let privacyURL = privacyPolicyURL {
            settings.termsAndPrivacyPolicyFlowSettings.isEnabled = true
            settings.termsAndPrivacyPolicyFlowSettings.privacyPolicyURL = URL(
                string: privacyURL
            )
        }

        if let termsURL = termsOfServiceURL {
            settings.termsAndPrivacyPolicyFlowSettings.termsOfServiceURL = URL(
                string: termsURL
            )
            settings.termsAndPrivacyPolicyFlowSettings
                .shouldShowTermsAndPrivacyPolicyAlertInGDPR = true

        }

        #if DEBUG

            if debugUserGeography {
                settings.termsAndPrivacyPolicyFlowSettings.debugUserGeography =
                    .GDPR
            }

            settings.isVerboseLoggingEnabled = isVerboseLoggingEnabled

            if showMediationDebugger {
                ALSdk.shared().showMediationDebugger()
            }

            if showCreativeDebugger {
                ALSdk.shared().showCreativeDebugger()
            }
        #endif
    }

    public func setup(
        sdkKey: String,
        units: ALMUnits,
        privacyPolicyURL: String? = nil,
        termsOfServiceURL: String? = nil,
        debugUserGeography: Bool = true,
        isVerboseLoggingEnabled: Bool = false,
        showMediationDebugger: Bool = false,
        showCreativeDebugger: Bool = false
    ) async {
        await setupUnits(units: units)
        await initAd(sdkKey: sdkKey)
        await updateSettings(
            privacyPolicyURL: privacyPolicyURL,
            termsOfServiceURL: termsOfServiceURL,
            debugUserGeography: debugUserGeography,
            isVerboseLoggingEnabled: isVerboseLoggingEnabled,
            showMediationDebugger: showMediationDebugger,
            showCreativeDebugger: showCreativeDebugger
        )
    }
}

//MARK: - Interstitial
extension ALMHelper {
    public func loadInterstitial() {
        guard configs.enableAds, configs.showInterstitial else {
            AdLog("Interstitial not ready")
            return
        }
        interstitialManager?.loadAd()
    }

    public func showInterstitial(
        placement: String = "",
        percent: Int? = nil,
        frequencyCapping: Int? = nil,
        _ completion: ((AdDisplayState) -> Void)? = nil
    ) {
        if configs.forceOrientationAd {
            let deviceOrientation = ALDeviceOrientation.current
            if deviceOrientation == .landscape {
                showLandscapeInterstitial(placement: placement, percent: percent, frequencyCapping: frequencyCapping, completion)
                return
            }
        }

        guard let interstitial = interstitialManager else {
            AdLog("Interstitial Manager has not been initialized.")
            return
        }

        guard configs.enableAds, configs.showInterstitial else {
            AdLog("Interstitial not ready")
            completion?(.notReady)
            return
        }

        let date = Date().timeIntervalSince1970

        let timeBetweenAds = date - ALMHelper.shared.openAdLastTime
        if timeBetweenAds < configs.timeBetweenAds.toDouble {
            AdLog("Interstitial time between ads: \(timeBetweenAds)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        let impressionPercentage =
            percent ?? configs.impressionPercentage
        let frequencyCapping =
            frequencyCapping ?? configs.frequencyCapping

        let diff = date - ALMHelper.shared.interstitialLastTime
        if diff < frequencyCapping.toDouble {
            AdLog("Interstitial frequency capping: \(diff)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        let randomPercent = Int.random(in: 0...99)
        AdLog(
            "impression percentage: \(impressionPercentage), random: \(randomPercent)"
        )
        if randomPercent < impressionPercentage {
            interstitial.showAds(placement: placement) { state in
                AdLog("Interstitial show state: \(state.title)")
                if state == .hidden {
                    ALMHelper.shared.interstitialLastTime =
                        Date().timeIntervalSince1970
                }

                completion?(state)
            }
        } else {
            AdLog("Interstitial don't show")
            if let completion = completion {
                completion(.notReady)
            }
        }
    }
}

//MARK: - Landscape Interstitial
extension ALMHelper {
    public func initLandscapeInterstitial() {
        let deviceOrientation = ALDeviceOrientation.current
        guard deviceOrientation == .landscape else {
            AdLog("Device is not in landscape orientation")
            return
        }

        guard let interstitialAdUnitId = self.adUnits.interstitialAdUnitId,
            interstitialAdUnitId.notNil
        else {
            AdLog("Landscape Interstitial not ready")
            return
        }

        self.interstitialLandscapeManager = InterstitialLandscapeManager(
            adUnitId: interstitialAdUnitId
        )
        
        AdLog("Landscape Interstitial has been initialized.")
    }

    public func loadLandscapeInterstitial() {
        guard configs.enableAds, configs.showInterstitial else {
            AdLog("Landscape Interstitial not ready")
            return
        }

        let deviceOrientation = ALDeviceOrientation.current
        guard deviceOrientation == .landscape else {
            AdLog("Device is not in landscape orientation")
            return
        }
        
        if interstitialLandscapeManager == nil {
            AdLog("Landscape Interstitial Manager has not been initialized.")
            initLandscapeInterstitial()
        }
        
        interstitialLandscapeManager?.loadAd()
    }

    public func showLandscapeInterstitial(
        placement: String = "",
        percent: Int? = nil,
        frequencyCapping: Int? = nil,
        _ completion: ((AdDisplayState) -> Void)? = nil
    ) {
        guard let interstitial = interstitialLandscapeManager else {
            AdLog("Landscape Interstitial Manager has not been initialized.")
            initLandscapeInterstitial()
            return
        }

        guard configs.enableAds, configs.showInterstitial else {
            AdLog("Landscape Interstitial not ready")
            completion?(.notReady)
            return
        }
        
        let deviceOrientation = ALDeviceOrientation.current
        guard deviceOrientation == .landscape else {
            AdLog("Device is not in landscape orientation")
            showInterstitial(placement: placement, percent: percent, frequencyCapping: frequencyCapping, completion)
            return
        }

        let date = Date().timeIntervalSince1970

        let timeBetweenAds = date - ALMHelper.shared.openAdLastTime
        if timeBetweenAds < configs.timeBetweenAds.toDouble {
            AdLog("Landscape Interstitial time between ads: \(timeBetweenAds)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        let impressionPercentage =
            percent ?? configs.impressionPercentage
        let frequencyCapping =
            frequencyCapping ?? configs.frequencyCapping

        let diff = date - ALMHelper.shared.interstitialLastTime
        if diff < frequencyCapping.toDouble {
            AdLog("Landscape Interstitial frequency capping: \(diff)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        let randomPercent = Int.random(in: 0...99)
        AdLog(
            "impression percentage: \(impressionPercentage), random: \(randomPercent)"
        )
        if randomPercent < impressionPercentage {
            interstitial.showAds(placement: placement) { state in
                AdLog("Landscape Interstitial show state: \(state.title)")
                if state == .hidden {
                    ALMHelper.shared.interstitialLastTime =
                        Date().timeIntervalSince1970
                }

                completion?(state)
            }
        } else {
            AdLog("Landscape Interstitial don't show")
            if let completion = completion {
                completion(.notReady)
            }
        }
    }
}

//MARK: - Open Ads
extension ALMHelper {
    public func loadOpenAds() {
        guard configs.enableAds, configs.showAoa else {
            AdLog("OpenAd not ready")
            return
        }
        openAdManager?.loadAd()
    }

    public func showOpenAds(
        placement: String = "",
        _ completion: ((AdDisplayState) -> Void)? = nil
    ) {
        guard let openAdManager = openAdManager else {
            AdLog("OpenAd Manager has not been initialized.")
            return
        }

        guard configs.enableAds, configs.showAoa else {
            AdLog("OpenAd not ready")
            completion?(.notReady)
            return
        }

        let date = Date().timeIntervalSince1970
        let timeBetweenAds = date - ALMHelper.shared.interstitialLastTime

        if timeBetweenAds < configs.timeBetweenAds.toDouble {
            AdLog("OpenAd time between ads: \(timeBetweenAds)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        openAdManager.showAds(placement: placement) { state in
            AdLog("OpenAd show state: \(state.title)")
            if state == .hidden {
                ALMHelper.shared.openAdLastTime = Date().timeIntervalSince1970
            }

            completion?(state)
        }
    }

    public func showResumeAds(
        placement: String = "",
        _ completion: ((AdDisplayState) -> Void)? = nil
    ) {
        guard let openAdManager = openAdManager else {
            AdLog("ResumeAd Manager has not been initialized.")
            return
        }

        guard configs.enableAds, configs.showResume else {
            AdLog("ResumeAd not ready")
            completion?(.notReady)
            return
        }

        let date = Date().timeIntervalSince1970
        let timeBetweenAds = date - ALMHelper.shared.interstitialLastTime

        if timeBetweenAds < configs.timeBetweenAds.toDouble {
            AdLog("OpenAd time between ads: \(timeBetweenAds)")
            if let completion = completion {
                completion(.notReady)
            }
            return
        }

        openAdManager.showAds(placement: placement) { state in
            AdLog("ResumeAd show state: \(state.title)")
            if state == .hidden {
                ALMHelper.shared.openAdLastTime = Date().timeIntervalSince1970
            }

            completion?(state)
        }
    }
}

//MARK: - Reward Ads
extension ALMHelper {
    public func loadRewardAd() {
        guard configs.enableAds, configs.showReward else {
            AdLog("RewardAd not ready")
            return
        }
        rewardManager?.loadAd()
    }

    public func showRewardAd(
        placement: String = "",
        _ completion: ((AdDisplayState) -> Void)? = nil
    ) {
        guard let rewardManager = rewardManager else {
            AdLog("RewardAd Manager has not been initialized.")
            return
        }

        guard configs.enableAds, configs.showReward else {
            AdLog("RewardAd not ready")
            completion?(.notReady)
            return
        }

        rewardManager.showAds(placement: placement) { state in
            AdLog("RewardAd show state: \(state.title)")
            if state == .hidden {
                ALMHelper.shared.rewardAdLastTime = Date().timeIntervalSince1970
            }

            completion?(state)
        }
    }
}

//MARK: - Native Ads + Banner Ads
/**
 Native ads + banner ads should be initialized using a dedicated class
 to enable reuse across multiple screens, avoid code duplication,
 and ensure better lifecycle management.

 Example: BannerAdManager helps manage banner ads for each screen.

 class ViewController: UiViewControlelr {
    private var bannerAd: BannerAdManager?
 }

 func loadAd() {
    self.bannerAd = BannerAdManager(adUnitId: Configurations.AdUnits.bannerAdUnitId)
    self.bannerAd?.loadBannerAd(parent: bannerView)
 }
 */

//MARK: - Banner Ads Utils
extension UIView {
    public func attachBanner(
        _ bannerManager: BannerAdManager? = nil,
        placement: String? = nil,
        shimmerColor: UIColor = .lightGray,
        delegate: ALMHelperDelegate? = nil
    ) {
        guard
            ALMHelper.shared.configs.enableAds
        else {
            AdLog("BannerAd is not enabled")
            return
        }

        var bannerAd: BannerAdManager?
        if let bannerManager = bannerManager {
            bannerAd = bannerManager
        } else if let adId = ALMHelper.shared.adUnits.bannerAdUnitId {
            bannerAd = BannerAdManager(adUnitId: adId)
        } else {
            return
        }

        if let delegate = delegate {
            bannerAd?.delegate = delegate
        }

        bannerAd?.loadBannerAd(
            parent: self,
            placement: placement,
            shimmerColor: shimmerColor
        )
    }
}
