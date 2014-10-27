Pod::Spec.new do |s|
  s.name         = "jest"
  s.version      = "0.1.0"
  s.summary      = "RestKit mapping descriptors."
  s.homepage     = "http://phamquy.github.io/jest/"
  s.author       = { "Jackode" => "psyquy@gmail.com" }
  s.license          =  'Apache License, Version 2.0'
  
  s.ios.deployment_target = '5.0'
  s.platform = :ios, '5.0'
  s.dependency 'RestKit', '~> 0.23'  
  s.framework  = 'CoreData'
  s.requires_arc = true
  s.public_header_files = 'jest/*.h'
  s.source =  { :git => 'https://github.com/phamquy/jest.git', :tag => "v0.1.0" }
  s.source_files  = 'jest/*.{h,m}'
  s.prefix_header_contents = '#import <CoreData/CoreData.h>'
end