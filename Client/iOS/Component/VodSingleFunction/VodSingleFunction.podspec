Pod::Spec.new do |s|
  s.name             = 'VodSingleFunction'
  s.version          = '0.1.1'
  s.summary          = 'BytePlus VOD SingleFunction'
  s.description      = <<-DESC
  BytePlus VOD
                       DESC
  s.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}

  s.ios.deployment_target = '11.0'
  
  $XCODE_VERSION = `xcrun xcodebuild -version | grep Xcode | cut -d' ' -f2`
  if $XCODE_VERSION >= '15.0.0'
    s.user_target_xcconfig = {"OTHER_LDFLAGS"=> "-ld64", }
  end

  s.public_header_files = [
    'Classes/**/*.{h}'
  ]
  s.source_files = [
    'Classes/**/*'
  ]
  s.dependency 'ToolKit/VodPlayer'
end
