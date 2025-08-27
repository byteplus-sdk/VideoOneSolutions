Pod::Spec.new do |spec|
  spec.name         = 'AIChat'
  spec.version      = "1.0.0"
  spec.summary      = "A short description of AIChat."
  spec.description  = <<-DESC
  RTC AIChat
                   DESC
  spec.homepage     = "https://github.com/byteplus-sdk/VideoOneSolutions"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author             = { 'author' => 'byteplus rtc'  }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '11.0'

    
  unless defined?($RTC_SDK)
    raise "Error: Variable $RTC_SDK is not defined in the podspec file."
  end

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.resource_bundles = {
    'AIChat' => ['Resources/*.xcassets', 'Resources/*.bundle']
  }
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"'
  spec.dependency 'ToolKit/RTC'
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'SDWebImage'
end
