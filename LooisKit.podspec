Pod::Spec.new do |s|
  s.name             = "LooisKit"
  s.version          = "0.0.5"
  s.summary          = "A wrapper for Trust and loois-relay"

  s.description      = <<-DESC
    A wrapper for Trust, used for loois ios sdk.
    DESC

  s.homepage         = "https://github.com/LOOIS-IO/loois-ios-sdk"
  s.license          = 'Apache License 2.0'
  s.author           = { "Daaaaahan" => "849565897@qq.com" }
  s.source           = { :git => 'https://github.com/LOOIS-IO/loois-ios-sdk.git', :tag => s.version }

  s.swift_version = '4.1'
  s.module_name = 'LooisKit'
  s.platform = :ios, '10.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }

  s.subspec 'Relay' do |ss|
    ss.source_files = 'LooisKit/Classes/RelayAPI/*.swift'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'LooisKit/Classes/Core/**/*.swift'
    ss.dependency 'TrustCore', '0.2.0'
    ss.dependency 'Result'
    ss.dependency 'CryptoSwift'
  end
end
