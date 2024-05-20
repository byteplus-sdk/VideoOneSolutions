Pod::Spec.new do |s|
  s.name         = "MediaLive"
  s.version      = "0.0.1"
  s.summary      = "BytePlus MediaLive."
  s.description  = <<-DESC
  BytePlus MediaLive 
                   DESC

  s.homepage     = "https://github.com/byteplus-sdk/VideoOneSolutions"
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}
  s.resource_bundle = {
    'MediaLive' => ['Resources/*.{xcassets,bundle}']
  }
  s.module_name = 'MediaLive'
  s.ios.deployment_target = '11.0'

  s.default_subspecs = 'Entry', 'Push', 'Pull', 'VELCommon', 'VELSettings', 'ScreenCapture'

  s.subspec 'Entry' do |subspec|
    subspec.source_files = 'Entry/Classes/**/*'
    subspec.public_header_files = 'Entry/Classes/**/*.h'
    subspec.resource = 'Entry/Assets/*.xcassets'
    subspec.dependency 'MediaLive/VELCommon'
    subspec.dependency 'MediaLive/VELSettings'
    subspec.dependency 'MediaLive/Push'
    subspec.dependency 'MediaLive/Pull'
    subspec.dependency 'ToolKit'
    subspec.dependency 'AppConfig'
  end

  s.subspec 'VELCommon' do |subspec|
    subspec.source_files = 'VELCommon/Classes/**/*.{h,m}'
    subspec.resources = 'VELCommon/Assets/**/*.{xcassets}'
    subspec.public_header_files = 'VELCommon/Classes/**/*.h'
    subspec.frameworks = 'UIKit'
    subspec.dependency 'Masonry'
    subspec.dependency 'AFNetworking'
  end

  s.subspec 'VELSettings' do |subspec|
    subspec.source_files = 'VELSettings/Classes/**/*.{h,m}'
    subspec.resources = 'VELSettings/Assets/*.xcassets'
    subspec.public_header_files = 'VELSettings/Classes/**/*.h'
    subspec.frameworks = 'UIKit'
    subspec.dependency 'MediaLive/VELCommon'
    subspec.dependency 'YYModel'
  end

  s.subspec 'Push' do |subspec|
    subspec.resources = 'Push/Assets/VELLivePush.xcassets'
    subspec.source_files = 'Push/Classes/**/*'
    subspec.public_header_files = 'Push/Classes/**/*.h'
    subspec.dependency 'MediaLive/VELCommon'
    subspec.dependency 'ToolKit'
    subspec.frameworks = [
      'VideoToolBox',
    ]
  end

  s.subspec 'Pull' do |subspec|
    subspec.source_files = 'Pull/Classes/**/*'
    subspec.resource_bundle = {
      'VELLiveDemo_Pull' => 'Pull/Assets/*.mp4'
    }
    subspec.public_header_files = 'Pull/Classes/**/*.h'
    subspec.dependency 'MediaLive/VELCommon'
    subspec.dependency 'ToolKit'
    subspec.frameworks = 'CoreAudio', 'AudioToolbox'
  end

  s.subspec 'ScreenCapture' do |subspec|
    subspec.source_files = [
      'ScreenCapture/Classes/*.{h,m,mm}'
    ]
    subspec.public_header_files = 'ScreenCapture/Classes/*.h'
    subspec.resource = 'ScreenCapture/Assets/*.mp3'
  end
  
end
