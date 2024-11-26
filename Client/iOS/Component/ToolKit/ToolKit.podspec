
Pod::Spec.new do |s|
  s.name         = 'ToolKit'
  s.version      = '1.0.0'
  s.summary      = 'Core'
  s.description  = 'Core ...'
  s.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}
  s.ios.deployment_target = '11.0'
  
  s.prefix_header_contents = '#import "Constants.h"'
  s.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  s.default_subspec = 'Common'
  s.public_header_files = 'ToolKit.h'
  s.source_files = 'ToolKit.h'
  
  s.subspec 'Common' do |subspec|
    subspec.public_header_files = 'Common/**/*.h'
    subspec.source_files = 'Common/**/*.{h,m,mm,hpp,cpp}'
    subspec.resource_bundles = {
      'ToolKit' => ['Common/Resource/*.{xcassets,bundle}']
    }
    subspec.dependency 'AppConfig'
    subspec.dependency 'Masonry'
    subspec.dependency 'YYModel'
    subspec.dependency 'AFNetworking'
  end
  
  s.subspec 'RTC' do |subspec|
    subspec.public_header_files = 'BaseRTCManager/**/*.h'
    subspec.source_files = 'BaseRTCManager/**/*.{h,m}'
    subspec.dependency 'ToolKit/Common'
    subspec.dependency $RTC_SDK
  end
  
  s.subspec 'LivePlayer' do |subspec|
    subspec.public_header_files = 'LivePlayerKit/**/*.h'
    subspec.source_files = 'LivePlayerKit/**/*.{h,m}'
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'TTSDK/LivePull'
  end
  
  s.subspec 'VodPlayer' do |subspec|
    subspec.public_header_files = [
      'VodPlayer/VEPlayerUIModule/Classes/**/*.h',
      'VodPlayer/VEPlayerKit/Classes/**/*.h',
      'VodPlayer/Model/Classes/**/*.h',
      'VodPlayer/VideoDetail/Classes/**/*.h',
      'VodPlayer/Data/**/*.h',
      'VodPlayer/VideoDetail/**/*.h',
    ]
    subspec.source_files = [
      'VodPlayer/VEPlayerUIModule/Classes/**/*',
      'VodPlayer/VEPlayerKit/Classes/**/*',
      'VodPlayer/Model/Classes/**/*',
      'VodPlayer/VideoDetail/Classes/**/*',
      'VodPlayer/Data/**/*',
      'VodPlayer/VideoDetail/**/*',
    ]
    subspec.resources = [
      'VodPlayer/VEPlayerUIModule/Resource/*.{json}'
    ]
    subspec.resource_bundle = {
      'VodPlayer' => 'VodPlayer/*.{xcassets,bundle}'
    }
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'AppConfig'
    subspec.dependency 'SDWebImage'
    subspec.dependency 'Masonry'
    subspec.dependency 'MJRefresh'
    subspec.dependency 'YYModel'
    subspec.dependency 'YYCache'
    subspec.dependency 'lottie-ios', '~> 2.0'
  end
  
  s.subspec 'LiveRoomUI' do |subspec|
    subspec.public_header_files = [
      'LiveRoomUI/Classes/**/*.h'
    ]
    subspec.source_files = [
      'LiveRoomUI/Classes/**/*'
    ]
    subspec.resource_bundle = {
      'LiveRoomUI' => 'LiveRoomUI/Resources/*.{xcassets,bundle}'
    }
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'Masonry'
  end
end
