Pod::Spec.new do |spec|
  spec.name         = 'NStackSDK'
  spec.version      = '2.0.1'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/nodes-ios/NStackSDK'
  spec.authors      = 'Nodes'
  spec.summary      = 'NStackSDK is the companion software development kit to the NStack backend.'
  spec.source       = { :git => 'https://github.com/nodes-ios/NStackSDK.git', :tag => spec.version }
  spec.source_files = "NStackSDK/NStackSDK/Classes/**/*.{h,m,swift}"
  spec.framework    = 'SystemConfiguration'
  spec.swift_version = '4.1'
  spec.platforms = { :ios => "8.0", :osx => "10.10", :watchos => "2.0", :tvos => "9.0" }
  spec.social_media_url   = "http://twitter.com/nodes_ios"

  spec.dependency 'Serpent'
  spec.dependency 'Alamofire'
  spec.dependency 'Cashier'

end