
Pod::Spec.new do |spec|
  spec.name         = 'ToolKit'
  spec.version      = '1.0.0'
  spec.summary      = 'Core'
  spec.description  = 'Core ...'
  spec.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '11.0'
  
  spec.prefix_header_contents = '#import "Constants.h"'
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.default_subspec = 'Common'
  spec.public_header_files = 'ToolKit.h'
  spec.source_files = 'ToolKit.h'
  
  spec.subspec 'Common' do |ss|
    ss.public_header_files = 'Common/**/*.h'
    ss.source_files = 'Common/**/*.{h,m}'
    ss.resource_bundles = {
      'ToolKit' => ['Common/Resource/*.{xcassets,bundle}']
    }
    ss.dependency 'AppConfig'
    ss.dependency 'Masonry'
    ss.dependency 'YYModel'
    ss.dependency 'AFNetworking'
  end
  
  spec.subspec 'RTC' do |ss|
    ss.public_header_files = 'BaseRTCManager/**/*.h'
    ss.source_files = 'BaseRTCManager/**/*.{h,m}'
    ss.dependency 'ToolKit/Common'
    ss.dependency 'TTSDK/RTC-Framework'
  end
  
  spec.subspec 'Player' do |ss|
    ss.public_header_files = 'PlayerKit/**/*.h'
    ss.source_files = 'PlayerKit/**/*.{h,m}'
    ss.dependency 'ToolKit/Common'
    ss.dependency 'TTSDK/LivePull'
  end
end
