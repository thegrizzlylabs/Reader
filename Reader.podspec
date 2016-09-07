Pod::Spec.new do |s|
 s.name = 'Reader'
 s.version = '2.8.6'
 s.license = 'MIT'
 s.summary = 'The open source PDF file reader/viewer for iOS.'
 s.homepage = 'http://www.vfr.org/'
 s.authors = { "Julius Oklamcak" => "joklamcak@gmail.com" }
 s.source = { :git => 'https://github.com/vfr/Reader.git', :tag => "v#{s.version}" }
 s.platform = :ios
 s.ios.deployment_target = '6.0'
 s.requires_arc = true
 s.default_subspecs = 'Core'

 s.subspec 'Core' do |core|
  core.source_files = 'Sources/**/*.{h,m}'
  core.resources = 'Graphics/Reader-*.png'
  core.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'QuartzCore', 'ImageIO', 'MessageUI'
 end

 s.subspec 'AppExtension' do |app_extension|
  app_extension.dependency 'Reader/Core'
  app_extension.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) RDR_APP_EXTENSIONS=1' }
 end
end
