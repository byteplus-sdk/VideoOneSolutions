Pod::Spec.new do |spec|
  spec.name         = 'RTCAPIExample'
  spec.version      = '1.0.0'
  spec.summary      = 'RTC API Example APP'
  spec.description  = 'RTC API Example App ..'
  spec.homepage     = 'https://github.com/byteplus-sdk'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus-sdk' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a,swift}'
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.resources = ['RTCAPIExample/Resource/**']
  spec.resource_bundles = {
    'APIExample' => ['RTCAPIExample/*.xcassets',
                     'RTCAPIExample/*.bundle']
  }
  unless defined?($RTC_SDK)
    raise "Error: Variable $RTC_SDK is not defined in the podspec file."
  end

  spec.dependency $RTC_SDK
  spec.dependency 'SnapKit'
  spec.dependency 'IQKeyboardManagerSwift'
end
