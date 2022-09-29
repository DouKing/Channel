Pod::Spec.new do |s|
  s.name             = 'Channel'
  s.version          = '0.1.0'
  s.summary          = 'iOS helper.'
  
  s.description      = <<-DESC
  A common function development kit for iOS.
                       DESC

  s.homepage         = 'https://github.com/douking/Channel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'douking' => 'wyk8916@gmail.com' }
  s.source           = { :git => 'https://github.com/douking/Channel.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.6'

  s.source_files = 'Source/**/*'
end
