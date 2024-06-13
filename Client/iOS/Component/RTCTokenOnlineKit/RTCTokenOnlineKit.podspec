Pod::Spec.new do |spec|
  spec.name         = 'RTCTokenOnlineKit'
  spec.version      = '1.0.0'
  spec.summary      = 'RTC Token Online Kit'
  spec.description  = 'RTC Token Online Kit ..'
  spec.homepage     = 'https://github.com/xxx'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'xxxx rtc' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5.0'
  
  spec.source_files = '**/*.{h,m,c,mm}'
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
end
