# Uncomment the next line to define a global platform for your project
platform :ios, '13.2'

target 'my MINK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for my MINK
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'FirebaseFirestoreSwift'
  pod 'FBSDKLoginKit'
  pod 'GoogleSignIn'
  pod 'MBProgressHUD'
  pod 'SDWebImage', '~> 5.0'
  pod 'CropViewController'
  pod 'IQKeyboardManagerSwift'
  pod 'MHLoadingButton'
  pod 'DropDown'
  pod 'TTGSnackbar'
  pod 'GooglePlaces'
  pod 'ALProgressView'
  pod 'lottie-ios'
  pod 'FirebaseFunctions'
  pod 'ATGMediaBrowser'
  pod "BSImagePicker"
  pod 'RevenueCat'
  pod 'RNCryptor'
  pod 'BraintreeDropIn'
  pod 'Alamofire'
  pod 'BranchSDK'
  pod 'FLAnimatedImage'
  pod 'ActiveLabel'
 pod 'SWXMLHash'
  pod 'SSZipArchive'
  pod 'Firebase/Crashlytics'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Set IPHONEOS_DEPLOYMENT_TARGET for all targets
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.2'
      
      # Handle xcconfig modifications
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      
      # Add Info.plist to specific frameworks
      if ['BraintreeDropIn', 'DropDown', 'DSPhotoEditorSDK', 'FirebaseFunctions', 'ATGMediaBrowser', 'BSImagePicker', 'RevenueCat', 'RNCryptor', 'ALProgressView'].include? target.name
        info_plist_path = File.join(installer.sandbox.root, target.name, 'Info.plist')

        plist_content = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.#{target.name}</string>
    <key>CFBundleName</key>
    <string>#{target.name}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>#{target.name}</string>
</dict>
</plist>
        EOS

        File.write(info_plist_path, plist_content)

        # Update the build settings to point to the new Info.plist
        config.build_settings['INFOPLIST_FILE'] = info_plist_path
      end
    end

    # Additional settings specific to BoringSSL-GRPC
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
