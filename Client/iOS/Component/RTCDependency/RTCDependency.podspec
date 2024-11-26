#
#  Be sure to run `pod spec lint RTCDependency.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "RTCDependency"
  s.version      = "3.58.1.20600"
  s.summary      = "RTC expansion functions"
  s.description  = <<-DESC
    RTC option dependency libraries.
                   DESC

  s.homepage         = 'https://www.byteplus.com/en/product/rtc'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'author' => 'byteplus' }
  s.source           = { :path => './'}
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.default_subspecs = 'audioeffect'

  s.subspec 'audioeffect' do |subspec|
    subspec.vendored_frameworks = [
      'bdaudioeffect.framework',
    ]
  end

  s.subspec 'ScreenCapture' do |subspec|
    subspec.vendored_frameworks = [
      'BytePlusRTCScreenCapturer.xcframework',
    ]
  end

end
