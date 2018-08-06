# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'LooisKit' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LooisKit
  pod 'Result'
  pod 'TrustCore', '0.2.0'
  pod 'TrustKeystore', '0.5.0'

  target 'LooisKitTests' do
    inherit! :search_paths
    # Pods for testing
    
    pod 'Quick'
    pod 'Nimble'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['TrustKeystore'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    
  end
end
