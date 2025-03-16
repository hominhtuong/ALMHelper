//
//  ALMUnits.swift
//  ALMHelper
//
//  Created by Mitu Ultra on 12/3/25.
//

public struct ALMUnits {
    public let openAdUnitId:            String?
    public let bannerAdUnitId:          String?
    public let interstitialAdUnitId:    String?
    public let rewardAdUnitId:          String?
    public let nativeAdUnitId:          String?

    public init(
        openAdUnitId:           String? = nil,
        bannerAdUnitId:         String? = nil,
        interstitialAdUnitId:   String? = nil,
        rewardAdUnitId:         String? = nil,
        nativeAdUnitId:         String? = nil
    ) {
        self.openAdUnitId = openAdUnitId
        self.bannerAdUnitId = bannerAdUnitId
        self.interstitialAdUnitId = interstitialAdUnitId
        self.rewardAdUnitId = rewardAdUnitId
        self.nativeAdUnitId = nativeAdUnitId
    }
}
