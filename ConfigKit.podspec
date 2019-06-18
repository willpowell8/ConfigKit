#
# Be sure to run `pod lib lint ConfigKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ConfigKit'
  s.version          = '0.4.10'
  s.summary          = 'Framework to manage your app configuration'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Remotely manage your configuration served from a git repository
                       DESC

  s.homepage         = 'https://github.com/willpowell8/ConfigKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Will Powell' => 'willpowell8@gmail.com' }
  s.source           = { :git => 'https://github.com/willpowell8/ConfigKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/willpowelluk'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.swift_version = '4.2'

  s.source_files = 'ConfigKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ConfigKit' => ['ConfigKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ReachabilitySwift', '~> 3'
end
