Pod::Spec.new do |spec|
  spec.name         = 'LiveSportStreaming'
  spec.version      = '1.0.0'
  spec.summary      = 'Live Sport Streaming Scene'
  spec.description  = <<-DESC
  Live Sport Streaming demonstrates TTSDK Live SDK low-latency, image enhancement and bandwidth-saving capabilities.
                   DESC
  spec.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  spec.author       = { 'author' => 'byteplus' }
  spec.source       = { :path => './' }
  spec.ios.deployment_target = '14.0'
  spec.static_framework = true

  spec.source_files  = 'Classes', 'Classes/**/*.{h,m,swift}'
  spec.resource_bundles = {
    'LiveSportStreaming' => ['Resources/*.xcassets', 'Resources/*.bundle']
  }

  spec.dependency 'ToolKit'
  spec.dependency 'ToolKit/LivePlayer'
  spec.dependency 'Masonry'
  spec.dependency 'SnapKit'
  spec.dependency 'SDWebImage'
  spec.dependency 'YYModel'

  spec.swift_versions = ['5.0']
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end
