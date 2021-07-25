# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BlossomApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlossomApp

  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Functions'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
#  pod 'FirebaseFirestoreSwift'
  
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  
  pod 'Alamofire'
  pod 'Kingfisher', '5.15.8'
  pod 'AdvancedPageControl'
  
  pod 'SVProgressHUD'
  
  pod 'DLRadioButton', '~> 1.4'
  
  pod 'ConnectyCube'
  pod 'ConnectyCubeCalls'
  pod 'CommonKeyboard'
  pod 'SwiftDate', '~> 5.1.0'
  pod 'BadgeSwift', '~> 7.0.0'
#  pod 'LetterAvatarKit', '~> 1.1.7'
#  pod 'PINRemoteImage', '~> 2.1.4'
#  pod 'Reusable', '~> 4.0.5'
  
  target 'BlossomAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BlossomAppUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
