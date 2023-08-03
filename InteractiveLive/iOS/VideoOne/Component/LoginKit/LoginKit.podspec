
Pod::Spec.new do |spec|
  spec.name         = 'LoginKit'
  spec.version      = '1.0.0'
  spec.summary      = 'LoginKit APP'
  spec.description  = 'LoginKit App ..'
  spec.homepage     = 'https://github.com/byteplus-sdk'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus rtc' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '9.0'
  
  spec.source_files = '**/*.{h,m,c,mm}'
  spec.resource_bundles = {
    'LoginKit' => ['Resource/*.{xcassets,bundle}', 'Resource/IconImage/*.{png,gif}']
  }
  spec.prefix_header_contents = '#import "Masonry.h"',
                                '#import "ToolKit.h"',
                                '#import "LoginConstants.h"'
  spec.dependency 'ToolKit'
  spec.dependency 'YYModel'
  spec.dependency 'Masonry'
end
