# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SoSoHappy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'SnapKit', '~> 5.6.0'
  pod 'SwiftLint'
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'DGCharts'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod 'FSCalendar'
  pod 'Then' 

  # Pods for SoSoHappy

  target 'SoSoHappyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SoSoHappyUITests' do
    # Pods for testing
  end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
end
