platform :ios, '11.0'

target 'Testing' do
  use_frameworks!
  
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'Hue', '~> 3.0'
  
  target 'TestingTests' do
    inherit! :search_paths
    pod 'RxTest', '~> 4.0'
    pod 'RxBlocking', '~> 4.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
