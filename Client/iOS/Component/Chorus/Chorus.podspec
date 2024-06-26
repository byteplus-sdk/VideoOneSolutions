Pod::Spec.new do |spec|
  spec.name         = 'Chorus'
  spec.version      = '1.0.0'
  spec.summary      = 'Chorus APP'
  spec.description  = 'Chorus App Demo..'
  spec.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus rtc' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '9.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a}'
  spec.resource_bundles = {
    'Chorus' => ['Resource/*.xcassets', 'Resource/*.bundle']
  }
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.resources = ['Resource/*.{jpg}']
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "ChorusConstants.h"',
                                '#import "ChorusUserModel.h"',
                                '#import "ChorusRoomModel.h"',
                                '#import "ChorusSongModel.h"'
                                
  spec.dependency 'ToolKit/RTC'
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'SDWebImage'
end
