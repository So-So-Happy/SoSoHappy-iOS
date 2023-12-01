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
  pod 'ReactorKit'
  pod 'RxKakaoSDK'
  pod 'GoogleSignIn'
  pod 'Moya', '~> 15.0'
  pod 'Moya/RxSwift', '~> 15.0'
  pod "RxGesture"
  pod 'RxKeyboard'
  pod 'RxDataSources', '~> 5.0'
  pod 'Starscream', '~> 4.0.6'
  pod 'NVActivityIndicatorView'
  pod 'JWTDecode', '~> 3.1'

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
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        end
      end
    end
  end
end
