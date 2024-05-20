Pod::Spec.new do |s|
  s.name             = 'VideoPlaybackEdit'
  s.version          = '0.1.1'
  s.summary          = 'BytePlus VOD Demo'
  s.description      = <<-DESC
  BytePlus VOD
                       DESC
  s.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}

  s.ios.deployment_target = '11.0'

  s.default_subspecs = 'VEPlayerUIModule', 'VEPlayerKit', 'VESceneKit', 'Setting', 'LongVideo', 'FeedVideo', 'ShortVideo', 'VideoDetail', 'Uploader', 'Entry', 'SingleFunction'
  
  $XCODE_VERSION = `xcrun xcodebuild -version | grep Xcode | cut -d' ' -f2`
  if $XCODE_VERSION >= '15.0.0'
    s.user_target_xcconfig = {"OTHER_LDFLAGS"=> "-ld64", }
  end

  s.subspec 'VEPlayerUIModule' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayerUIModule/Classes/**/*.h'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayerUIModule/Classes/**/*'
    ]
    subspec.resources = [
      'VEVodApp/VEPlayerUIModule/VEVodApp.xcassets',
      'VEVodApp/VEPlayerUIModule/Resource/*.{json}'
    ]
    subspec.resource_bundle = {
      'VEVodApp' => 'VEVodApp/VEPlayerUIModule/*.bundle'
    }
    subspec.dependency 'AppConfig'
    subspec.dependency 'SDWebImage'
    subspec.dependency 'Masonry'
    subspec.dependency 'MJRefresh'
    subspec.dependency 'YYModel'
    subspec.dependency 'YYCache'
    subspec.dependency 'ToolKit'
    subspec.dependency 'lottie-ios', '~> 2.0'
  end

  s.subspec 'VEPlayerKit' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayerKit/Classes/**/*.h'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayerKit/Classes/**/*'
    ]
    subspec.dependency 'TTSDK/Player'
    subspec.dependency 'AppConfig'
    subspec.dependency 'SDWebImage'
    subspec.dependency 'Masonry'
    subspec.dependency 'ToolKit'
  end

  s.subspec 'VESceneKit' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VESceneKit/Classes/**/*.h'
    ]
    subspec.source_files = [
      'VEVodApp/VESceneKit/Classes/**/*'
    ]
  end

  s.subspec 'Setting' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayModule/Classes/Data/**/*.{h}',
      'VEVodApp/VEPlayModule/Classes/Setting/**/*.{h}',
      'VEVodApp/VEPlayModule/Classes/Util/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayModule/Classes/Data/**/*',
      'VEVodApp/VEPlayModule/Classes/Setting/**/*',
      'VEVodApp/VEPlayModule/Classes/Util/**/*',
    ]
    subspec.resources = [
      'VEVodApp/VEPlayModule/Classes/Setting/**/*.{xib}'
    ]
    subspec.dependency 'VideoPlaybackEdit/VEPlayerKit'
    subspec.dependency 'VideoPlaybackEdit/VEPlayerUIModule'
  end

  s.subspec 'LongVideo' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayModule/Classes/LongVideo/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayModule/Classes/LongVideo/**/*'
    ]
    subspec.resources = [
      'VEVodApp/VEPlayModule/Classes/LongVideo/**/*.{xib}'
    ]
    subspec.dependency 'VideoPlaybackEdit/VideoDetail'
  end

  s.subspec 'FeedVideo' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayModule/Classes/FeedVideo/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayModule/Classes/FeedVideo/**/*'
    ]
    subspec.resources = [
      'VEVodApp/VEPlayModule/Classes/FeedVideo/**/*.{xib}'
    ]
    subspec.dependency 'VideoPlaybackEdit/VideoDetail'
  end

  s.subspec 'ShortVideo' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEPlayModule/Classes/ShortVideo/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayModule/Classes/ShortVideo/**/*'
    ]
    subspec.dependency 'VideoPlaybackEdit/VESceneKit'
    subspec.dependency 'VideoPlaybackEdit/VideoDetail'
  end

  s.subspec 'VideoDetail' do |subspec|
    subspec.public_header_files = [
    'VEVodApp/VEPlayModule/Classes/VideoDetail/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEPlayModule/Classes/VideoDetail/**/*'
    ]
    subspec.dependency 'VideoPlaybackEdit/Setting'
    subspec.dependency 'VideoPlaybackEdit/VEPlayerUIModule'
  end

  s.subspec 'Uploader' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/VEUploader/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/VEUploader/**/*'
    ]
    subspec.dependency 'TTSDK/Uploader'
    subspec.dependency 'YYModel'
    subspec.dependency 'ToolKit'
  end

  s.subspec 'Entry' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/Main/Entry/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/Main/Entry/**/*'
    ]
    subspec.dependency 'VideoPlaybackEdit/ShortVideo'
    subspec.dependency 'VideoPlaybackEdit/FeedVideo'
    subspec.dependency 'VideoPlaybackEdit/LongVideo'
    subspec.dependency 'VideoPlaybackEdit/Setting'
  end
  
  s.subspec 'SingleFunction' do |subspec|
    subspec.public_header_files = [
      'VEVodApp/SingleFunction/**/*.{h}'
    ]
    subspec.source_files = [
      'VEVodApp/SingleFunction/**/*'
    ]
    subspec.dependency 'VideoPlaybackEdit/VideoDetail'
  end
end
