#
# Be sure to run `pod lib lint RealmPersistable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RealmPersistable'
  s.version          = '0.2.0'
  s.summary          = 'This library extends RealmSwift with handsome extensions to improve usability of Realm based on Best Practises and other Libraries.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    This library is a personal toolset to extend RealmSwift with handsome extensions, whose improve usability of Realm based on best practises from gists and other libraries like EasyRealm. Code from third party Libraries are copied directly to the project to be avoid multiple dependency.
    DESC


  s.homepage         = 'https://github.com/alexanderkorus/RealmPersistable'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Korus' => 'alexander.korus@svote.io' }
  s.source           = { :git => 'https://github.com/alexanderkorus/RealmPersistable.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'Source/**/*'
  
  # s.resource_bundles = {
  #   'RealmPersistable' => ['RealmPersistable/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RealmSwift', '5.5.2'
end
