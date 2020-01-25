Pod::Spec.new do |spec|
    spec.name                   = 'LiveShopperSDK'
    spec.version                = '0.0.1'
    spec.summary                = 'Official LiveShopper SDK for iOS to access LiveShopper Platform.'
    spec.description            = <<-DESC
                                    LiveShopper allows you to crowd source REAL data
                                    from existing REAL customers. It is a modern,
                                    real time solution that makes mystery shopping
                                    obsolete. LiveShopper is a platform for issuing
                                    and accepting feedback tasks online.
                                  DESC

    spec.authors                = { 'LiveShopper' => 'support-github@liveshopper.com' }
    spec.homepage               = 'https://github.com/liveshopper/liveshopper-sdk-ios'
    spec.license                = { :type => 'Liveshopper Platform License', :file => 'LICENSE' }

    spec.frameworks             = 'CoreLocation'
    spec.ios.deployment_target  = '10.0'
    spec.module_name            = 'LiveShopperSDK'
    spec.platform               = :ios
    spec.requires_arc           = true
    spec.source                 = { :git => 'https://github.com/liveshopper/liveshopper-sdk-ios.git', :tag => "v#{spec.version}" }
    spec.source_files           = "LiveShopperSDK/LiveShopperSDK.framework/Headers/*.h"
    spec.swift_versions         = ['5.0', '5.1']
    spec.vendored_frameworks    = './framework/LiveShopperSDK.framework'
  end
