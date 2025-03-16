Pod::Spec.new do |spec|
    spec.name         = "ALMHelper"
    spec.version      = "1.0.3"
    spec.summary      = "🚀 ALMHelper – Simplify Applovin MAX Ad Integration"
    spec.swift_versions = ['5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9']
    spec.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Onone' }

    spec.static_framework = true

    spec.description  = <<-DESC
    Effortlessly load, manage, and display Applovin MAX ads with ALMHelper! Featuring a streamlined API, enhanced delegate mechanisms, and intelligent ad handling, ALMHelper makes ad integration seamless and efficient.
    DESC

    spec.homepage     = "https://mituultra.com/"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author       = { "Mitu Ultra" => "support@mituultra.com" }
    spec.platform     = :ios, "14.0"
    spec.ios.deployment_target = '14.0'

    spec.source       = { :git => "https://github.com/hominhtuong/ALMHelper.git", :tag => "#{spec.version}" }
    spec.source_files = 'Sources/*.swift'

    spec.dependency 'MiTuKit'
    spec.dependency 'AppLovinSDK'
    spec.dependency 'SkeletonView'
    spec.dependency 'GoogleUserMessagingPlatform'

end
