
Pod::Spec.new do |s|
  s.name         = 'MiniDrama'
  s.version      = '1.0.0'
  s.summary      = 'MiniDrama Scene'
  s.description  = 'MiniDrama Scene'
  s.homepage     = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license      = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author       = { 'author' => 'byteplus' }
  s.source       = { :path => './'}
  s.ios.deployment_target = '11.0'
  s.default_subspec = 'Entry'

  s.resource_bundles = {
    'MiniDrama' => ['Resources/*.{xcassets,bundle}']
  }

  s.subspec 'Player' do |subspec|
    subspec.public_header_files = [
      'Classes/Player/*.{h}'
    ]
    subspec.source_files = [
      'Classes/Player/**/*.{h,m}'
    ]
    subspec.dependency 'ToolKit/Common'
  end
  
  s.subspec 'Main' do |subspec|
    subspec.public_header_files = [
      'Classes/Main/**/*.{h}'
    ]
    subspec.source_files = [
      'Classes/Main/**/*.{h,m}'
    ]
    subspec.dependency 'MiniDrama/Player'
    subspec.dependency 'YYModel'
    subspec.dependency 'MJRefresh'
    subspec.dependency 'Reachability'
    subspec.dependency 'MBProgressHUD', '~> 1.2.0'
    subspec.dependency 'ToolKit/Common'
  end

  s.subspec 'Entry' do |subspec|
    subspec.public_header_files = [
      'Classes/Entry/*.{h}'
    ]
    subspec.source_files = [
      'Classes/Entry/*.{h,m}'
    ]
    subspec.dependency 'MiniDrama/Main'
    subspec.dependency 'ToolKit/Common'
  end

end
