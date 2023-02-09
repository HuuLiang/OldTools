#
# Be sure to run `pod lib lint HLSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HLSwiftKit'
  s.version          = '0.0.1'
  s.summary          = 'A short description of HLSwiftKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                    Hello world!
                       DESC

  s.homepage         = 'https://github.com/HuuLiang/HLSwiftKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '牛氓' => 'liangola@qq.com' }
  s.source           = { :git => 'https://github.com/HuuLiang/HLSwiftKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  
  s.swift_version = '5.0'
  
  s.source_files = 'HLSwiftKit/Core/**/*','HLSwiftKit/Components/**/*'
  s.resource_bundles = {
      'PKHUDResources' => ['HLSwiftKit/Assets/Images.xcassets']
  }
  s.dependency 'Aspects', '~> 1.4.1'
  s.dependency 'SnapKit', '5.0.1'
  s.dependency 'SwiftDate', '6.3.1'
  s.dependency 'Kingfisher', '~> 6.3.1'
  s.dependency 'MJRefresh' , '~> 3.7.5'
  s.dependency 'RxSwift', '6.5.0'
  s.dependency 'RxCocoa', '6.5.0'
  s.dependency 'Alamofire', '5.6.1'
  s.dependency 'AlamofireNetworkActivityIndicator', '~> 3.1.0'
  
  s.ios.frameworks = 'Foundation','UIKit'

  
#  s.default_subspecs = 'Core','Refresh','Hud','Rx','Net','Empty'
#
#  s.subspec 'Core' do |core|
#      core.source_files           = 'HLSwiftKit/Core/**/*'
#      core.dependency 'Aspects', '~> 1.4.1'
#      core.dependency 'SnapKit', '5.0.1'
#      core.dependency 'SwiftDate', '6.3.1'
#      core.dependency 'Kingfisher', '~> 6.3.1'
#      core.ios.frameworks = 'Foundation','UIKit'
#  end
#
#  s.subspec 'Refresh' do |refresh|
#      refresh.source_files        = 'HLSwiftKit/Components/Refresh/*'
#      refresh.dependency 'MJRefresh' , '~> 3.7.5'
#      refresh.dependency 'HLSwiftKit/Core'
#  end
#
#  s.subspec 'Hud' do |hud|
#      hud.source_files        = 'HLSwiftKit/Components/Hud/**/*'
#      hud.resource_bundle     = { 'PKHUDResources' => 'HLSwiftKit/Assets/Images.xcassets' }
#  end
#
#  s.subspec 'Rx' do |rx|
#      rx.source_files        = 'HLSwiftKit/Components/Rx/**/*'
#      rx.dependency 'RxSwift', '6.5.0'
#      rx.dependency 'RxCocoa', '6.5.0'
#  end
#
#  s.subspec 'Net' do |net|
#      net.source_files        = 'HLSwiftKit/Components/Net/**/*'
#      net.dependency 'Alamofire', '5.6.1'
#      net.dependency 'AlamofireNetworkActivityIndicator', '~> 3.1.0'
#  end
#
#  s.subspec 'Empty' do |empty|
#      empty.source_files        = 'HLSwiftKit/Components/Empty/**/*'
#  end

  # s.resource_bundles = {
  #   'HLSwiftKit' => ['HLSwiftKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
end
