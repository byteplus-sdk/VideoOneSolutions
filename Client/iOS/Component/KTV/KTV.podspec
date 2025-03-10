Pod::Spec.new do |spec|
  spec.name         = 'KTV'
  spec.version      = '1.0.0'
  spec.summary      = 'KTV APP'
  spec.description  = 'KTV App ..'
  spec.homepage     = 'https://github.com/volcengine'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'volcengine rtc' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '11.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a}'
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.resources = ['Resource/*.{jpg}']
  spec.resource_bundles = {
    'KTV' => ['Resource/*.xcassets',
                  'Resource/*.bundle']
  }
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "KTVConstants.h"',
                                '#import "KTVUserModel.h"',
                                '#import "KTVSeatModel.h"',
                                '#import "KTVRoomModel.h"',
                                '#import "KTVSongModel.h"'
  unless defined?($RTC_SDK)
    raise "Error: Variable $RTC_SDK is not defined in the podspec file."
  end
  spec.dependency 'ToolKit/RTC'
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'SDWebImage'
end
