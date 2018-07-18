Pod::Spec.new do |s|
s.name             = "LooisKit"
s.version          = "0.0.1"
s.summary          = "A wrapper for web3swift and loois-relay"

s.description      = <<-DESC
A wrapper for web3swift, used for loois ios sdk.
DESC

s.homepage         = "https://github.com/LOOIS-IO/loois-ios-sdk"
s.license          = 'Apache License 2.0'
s.author           = { "Daaaaahan" => "849565897@qq.com" }
s.source           = { :git => 'https://github.com/LOOIS-IO/loois-ios-sdk.git', :tag => s.version }

s.swift_version = '4.1'
s.module_name = 'LooisKit'
s.platform = :ios, '9.0'
s.source_files = 'LooisKit/Classes/**/*.{h,swift}'
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.subspec 'Relay' do |relay|
relay.source_files = 'LooisKit/Classes/RelayAPI'
end

s.subspec 'Base' do |base|
base.source_files = 'LooisKit/Classes/Base'
base.dependency 'looisweb3swift'
end


end