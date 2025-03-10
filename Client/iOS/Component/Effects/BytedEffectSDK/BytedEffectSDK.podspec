Pod::Spec.new do |spec|
  spec.name         = 'BytedEffectSDK'
  spec.version      = '4.4.3' 
  spec.summary      = 'Demo for effect-sdk'
  spec.description  = 'Demo for effect-sdk'
  spec.homepage     = 'https://github.com/byteplus'
  spec.license      = { :type => 'Copyright', :text => 'Bytedance copyright' }
  spec.author       = { 'byteplus' => 'byteplus@byteplus.com' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '11.0'
  spec.vendored_frameworks = 'effect-sdk.framework'
  spec.requires_arc = true
  spec.libraries = 'stdc++', 'z'
  spec.frameworks   = 'Accelerate','AssetsLibrary','AVFoundation','CoreGraphics','CoreImage','CoreMedia','CoreVideo','Foundation','QuartzCore','UIKit','CoreMotion'
  spec.weak_frameworks = 'Metal','MetalPerformanceShaders', 'Photos', 'CoreML'
end