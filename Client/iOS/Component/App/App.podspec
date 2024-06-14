#
# Be sure to run `pod lib lint App.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'App'
  s.version          = '0.1.0'
  s.summary          = 'Entry of App.'
  s.description      = <<-DESC
  Entry of App.
  DESC

  s.homepage         = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'author' => 'byteplus' }
  s.source           = { :path => './'}
  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'
  s.resource_bundle = {
    'App' => ['Assets/*.{xcassets,bundle}']
  }
  s.dependency 'ToolKit'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
end
