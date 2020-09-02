Pod::Spec.new do |spec|
    spec.name                   = 'LiveShopperSDK'
    spec.version                = '0.2.2'
    spec.summary                = 'Official LiveShopper SDK for iOS to access LiveShopper Platform.'
    spec.homepage               = 'https://liveshopper.com'
    spec.description            = <<-DESC
                                    LiveShopper allows you to crowd source REAL data
                                    from existing REAL customers. It is a modern,
                                    real time solution that makes mystery shopping
                                    obsolete. LiveShopper is a platform for issuing
                                    and accepting feedback tasks online.
                                  DESC

    spec.authors                = { 'LiveShopper' => 'support-github@liveshopper.com' }
    spec.frameworks             = 'CoreLocation'
    spec.ios.deployment_target  = '10.0'
    spec.license                = { :type => 'Liveshopper Platform License', :file => 'LICENSE' }
    spec.module_name            = 'LiveShopperSDK'
    spec.public_header_files    = 'dist/LiveShopperSDK.framework/Headers/*.h'
    spec.requires_arc           = true
    spec.source                 = { :git => 'https://github.com/liveshopper/liveshopper-sdk-ios.git', :tag => spec.version.to_s }
    spec.source_files           = 'dist/LiveShopperSDK.framework/Headers/*.h'
    spec.swift_versions         = ['5.0', '5.1', '5.2']
    spec.vendored_frameworks    = 'dist/LiveShopperSDK.framework'
  end
