//
//  SplashViewController.swift
//  Example
//
//  Created by Mitu Ultra on 14/3/25.
//

import ALMHelper
import MiTuKit

//MARK: Init and Variables
class SplashViewController: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    //Variables
    let loadingLabel = LoadingLabel()
    
    let bannerView = UIView()
}

//MARK: Lifecycle
extension SplashViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupAd()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: Functions
extension SplashViewController {
    private func setupView() {
        view.backgroundColor = .random
        
        let loadingText = "Loading..."
        let font: UIFont = .bold(20)
        let width: CGFloat = loadingText.width(height: 30, font: font) + 16
        
        loadingLabel >>> view >>> {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(width)
                $0.height.equalTo(30)
            }
            $0.textColor = .black
            $0.text = loadingText
            $0.startAnimating()
        }
        
        bannerView >>> view >>> {
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(botSafe)
                $0.height.equalTo(50)
            }
        }
    }
    
    func setupAd() {
        Task {
            let adUnits = ALMUnits(
                openAdUnitId: Configurations.AdUnits.openAdUnitId,
                bannerAdUnitId: Configurations.AdUnits.bannerAdUnitId,
                adaptiveBannerAdUnitId: Configurations.AdUnits.adaptiveBannerAdUnitId,
                interstitialAdUnitId: Configurations.AdUnits
                    .interstitialAdUnitId,
                rewardAdUnitId: Configurations.AdUnits.rewardAdUnitId,
                nativeAdUnitId: Configurations.AdUnits.nativeAdUnitId
            )
            await ALMHelper.shared.setup(
                sdkKey: Configurations.applovinSDKKey, units: adUnits)
            
            //Load configs online then setup
            ALMHelper.shared.configs.enableAds = true
            ALMHelper.shared.configs.showInterstitial = true
            ALMHelper.shared.configs.forceOrientationAd = true
            ALMHelper.shared.configs.orientation = .portrait // Setting this will force ads to load and display only in portrait mode.
            //...
            
            await delay(0.5)
            self.bannerView.attachBanner(placement: "SPLASH")
            
            await delay(1)
            ALMHelper.shared.loadInterstitial()
            
            await delay(2)
            self.loadingLabel.stopAnimating()
            
            //...
            self.goToMain()
        }
    }
    
    func goToMain() {
        if let window = currentWindow() {
            let navigation = UINavigationController(
                rootViewController: ViewController())
            window.rootViewController = navigation
            window.makeKeyAndVisible()
            
            UIView.transition(
                with: window, duration: 0.5, options: .transitionCrossDissolve,
                animations: {}, completion: nil)
        } else {
            self.navigationController?.pushViewController(
                ViewController(), animated: true)
        }
    }
}
