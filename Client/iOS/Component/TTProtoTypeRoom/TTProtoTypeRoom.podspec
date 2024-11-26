Pod::Spec.new do |s|
  s.name             = 'TTProtoTypeRoom'
  s.version          = '0.0.1'
  s.summary          = 'BytePlus TT ProtoType Demo'
  s.description      = <<-DESC
  BytePlus VOD
                       DESC
  s.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}

  s.ios.deployment_target = '11.0'

  s.default_subspecs = 'Entry', 'FeedModule'
  s.resource_bundles = {
    'TTProto' => ['Resources/*.{xcassets,bundle}']
  }
  $XCODE_VERSION = `xcrun xcodebuild -version | grep Xcode | cut -d' ' -f2`
  if $XCODE_VERSION >= '15.0.0'
    s.user_target_xcconfig = {"OTHER_LDFLAGS"=> "-ld64", }
  end

  s.subspec 'LivePlayer' do |subspec|
    subspec.public_header_files = [
      'Classes/LivePlayer/**/*.{h}'
    ]
    subspec.source_files = [
      'Classes/LivePlayer/**/*'
    ]
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'TTSDK/LivePull-RTS'
  end

  s.subspec 'RTCManager' do |subspec|
    subspec.public_header_files = [
      'Classes/RTCManager/**/*.{h}'
    ]
    subspec.source_files = [
      'Classes/RTCManager/**/*'
    ]
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'ToolKit/RTC'
    subspec.dependency 'TTSDK/LivePull-RTS'
  end


  s.subspec 'FeedModule' do |subspec|
    subspec.public_header_files = [
      'Classes/FeedModule/**/*.{h}'
    ]
    subspec.source_files = [
      'Classes/FeedModule/**/*'
    ]
    subspec.dependency 'Masonry'
    subspec.dependency 'ToolKit/Common'
    subspec.dependency 'ToolKit/VodPlayer'
    subspec.dependency 'ToolKit/LiveRoomUI'
    subspec.dependency 'TTProtoTypeRoom/LivePlayer'
    subspec.dependency 'TTProtoTypeRoom/RTCManager'
  end
  
  s.subspec 'Entry' do |subspec|
    subspec.public_header_files = [
      'Classes/Entry/*.{h}'
    ]
    subspec.source_files = [
      'Classes/Entry/**/*'
    ]
    
    subspec.dependency 'TTProtoTypeRoom/FeedModule'
  end
  
end
