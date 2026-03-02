Pod::Spec.new do |s|
  s.name             = "AdobeBranchExtension"
  s.version          = "5.0.0-beta.1"
  s.summary          = "The Branch extension for Adobe Cloud Platform on iOS."

  s.description      = <<-DESC
Add the power of Branch deep linking and attribution to your Adobe Marketing Cloud app.
With Branch's platform, mobile developers and marketers can leverage their app content to improve discoverability and optimize mobile campaigns.
                       DESC

  s.homepage         = "https://github.com/BranchMetrics/AdobeBranchExtension-iOS"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Branch Metrics" => "support@branch.io" }
  s.source           = { :git => "https://github.com/BranchMetrics/AdobeBranchExtension-iOS.git", :tag => s.version.to_s }

  s.platform         = :ios, '12.0'
  s.requires_arc     = true
  s.static_framework = true

  s.source_files = 'AdobeBranchExtension/Classes/**/*.{h,m}'
  s.public_header_files = 'AdobeBranchExtension/Classes/include/*.h'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/AdobeBranchExtension/Classes/include"'
  }

  s.dependency 'AEPCore',        '~> 5.1.0'
  s.dependency 'AEPLifecycle',   '~> 5.1.0'
  s.dependency 'AEPIdentity',    '~> 5.1.0'
  s.dependency 'AEPSignal',      '~> 5.1.0'
  s.dependency 'BranchSDK',      '~> 3.13.3'
end