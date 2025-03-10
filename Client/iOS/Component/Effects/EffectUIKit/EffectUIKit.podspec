Pod::Spec.new do |s|
  s.name             = 'EffectUIKit'
  s.version          = '0.1.0'
  s.summary          = '美颜UI模块'
  s.description      = <<~DESC
    美颜UI模块
  DESC

  s.homepage         = 'https://github.com/byteplus/EffectUIKit'
  s.license          = { :type => 'MIT' }
  s.author           = { 'byteplus' => 'byteplus' }
  s.source           = { :git => 'https://github.com/volcengine/EffectUIKit.git', :tag => s.version.to_s }
  s.module_name = 'EffectUIKit'
  s.platform     = :ios, '11.0'
  s.requires_arc = true
  s.static_framework = true
  s.source_files = 'EffectUIKit/Classes/**/*.{h,m}'
  s.resource_bundle = {
    'EffectUIKit' => 'EffectUIKit/Assets/*.{lproj,xcassets,json,plist}'
  }
  s.public_header_files = 'EffectUIKit/Classes/*.h'
  s.dependency 'Masonry'
end
