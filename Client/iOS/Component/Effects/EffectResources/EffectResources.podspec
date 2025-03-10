
Pod::Spec.new do |s|
  s.name             = 'EffectResources'
  s.version          = '0.1.0'
  s.summary          = 'A short description of EffectsResources.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/volcengine'
  s.license          = { :type => 'MIT' }
  s.author           = { 'byteplus' => 'byteplus' }
  s.source           = { :path => './' }
  s.ios.deployment_target = '11.0'
  s.resources = ['Assets/*.{bundle}']

end
