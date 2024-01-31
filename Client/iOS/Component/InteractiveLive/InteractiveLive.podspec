
Pod::Spec.new do |spec|
  spec.name         = 'InteractiveLive'
  spec.version      = '1.0.0'
  spec.summary      = 'Interactive Live APP'
  spec.description  = 'Interactive Live App Demo..'
  spec.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '11.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a}'
  spec.resource_bundles = {
    'InteractiveLive' => ['Resource/*.{xcassets,bundle}']
  }
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "LiveRTSManager.h"',
                                '#import "InteractiveLiveConstants.h"'
    
  spec.dependency 'ToolKit/RTC'
  spec.dependency 'ToolKit/Player'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'MJRefresh'
  spec.dependency 'TTSDK/LivePush-RTS'
  spec.dependency 'TTSDK/LivePull-RTS'
end
