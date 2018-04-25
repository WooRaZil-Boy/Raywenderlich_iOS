platform :ios, '11.0'

target 'RealmPlayground' do
  use_frameworks!
  pod 'RealmSwift', '3.3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
