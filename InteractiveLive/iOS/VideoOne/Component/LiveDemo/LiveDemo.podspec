
Pod::Spec.new do |spec|
  spec.name         = 'LiveDemo'
  spec.version      = '1.0.0'
  spec.summary      = 'LiveDemo APP'
  spec.description  = 'LiveDemo App Demo..'
  spec.homepage     = 'https://github.com/volcengine'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'volcengine rtc' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '9.0'
  
  spec.source_files = '**/*.{h,m,c,mm,a}'
  spec.resource_bundles = {
    'LiveDemo' => ['Resource/*.{xcassets,bundle}']
  }
  spec.pod_target_xcconfig = {'CODE_SIGN_IDENTITY' => ''}
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "LiveRTSManager.h"',
                                '#import "LiveDemoConstants.h"'
    
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
  spec.dependency 'TTSDK/LivePush-RTS'
  spec.dependency 'TTSDK/LivePull-RTS'
end
