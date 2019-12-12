Pod::Spec.new do |s|
  s.name             = "AdobeBranchExtension"
  s.version          = "1.2.1"
  s.summary          = "The Branch extension for Adobe Cloud Platform on iOS."

  s.description      = <<-DESC
#Add the power of Branch deep linking and attribution to your Adobe Marketing Cloud app.

#With Branch's platform, mobile developers and marketers can leverage
#their app content to improve discoverability and optimize mobile campaigns.
                       DESC

  s.homepage         = "https://github.com/BranchMetrics/AdobeBranchExtension-iOS"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Branch Metrics" => "support@branch.io" }
  s.source           = { :git => "https://github.com/BranchMetrics/AdobeBranchExtension-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/branchmetrics'

  s.platform         = :ios, '10.0'
  s.requires_arc     = true
  s.static_framework = true

  s.source_files     = 'AdobeBranchExtension/Classes/**/*'

  s.dependency 'ACPCore',   '~> 2.3'
  s.dependency 'Branch',    '= 0.31.0'
end
