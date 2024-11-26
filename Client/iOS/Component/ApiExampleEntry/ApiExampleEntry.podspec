#
#  Be sure to run `pod spec lint ApiExampleEntry.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "ApiExampleEntry"
  s.version      = "0.0.1"
  s.summary      = "Entry of ApiExample"
  s.description  = <<-DESC
  Entry of ApiExample
                   DESC

  s.homepage         = 'https://github.com/byteplus-sdk/VideoOneSolutions'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'author' => 'byteplus' }
  s.source           = { :path => './'}
  s.ios.deployment_target = '11.0'
  s.resource_bundle = {
    'ApiExampleEntry' => ['Assets/*.{xcassets,bundle}']
  }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
end
