
Pod::Spec.new do |spec|
  spec.name         = 'LoginKit'
  spec.version      = '1.0.0'
  spec.summary      = 'LoginKit APP'
  spec.description  = 'LoginKit App ..'
  spec.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '11.0'
  
  spec.source_files = '**/*.{h,m,c,mm}'
  spec.resource_bundles = {
    'LoginKit' => ['Resource/*.{xcassets,bundle}']
  }
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "LoginConstants.h"'
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
end
