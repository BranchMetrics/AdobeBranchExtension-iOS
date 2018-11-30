Pod::Spec.new do |s|
  s.name             = "AdobeBranchExtension"
  s.version          = "0.1.0"
  s.summary          = "The Branch extension for Adobe Cloud Platform on iOS."

  s.description      = <<-DESC
Add the power of Branch deep linking and analytics to your Adobe Marketing Cloud app.

With Branch's deep linking platform, mobile developers and marketers can leverage
their app content to improve discoverability and optimize install campaigns.

This is the Branch extension for the Adobe Marketing Cloud iOS library.
                       DESC

  s.homepage         = "https://github.com/BranchMetrics/AdobeBranchExtension-iOS"
  s.license          = 'MIT'
  s.author           = { "Branch Metrics" => "support@branch.io" }
  s.source           = { :git => "https://github.com/BranchMetrics/AdobeBranchExtension-iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/branchmetrics'

  s.platform         = :ios, '10.0'
  s.requires_arc     = true

  s.source_files     = 'AdobeBranchExtension/Classes/**/*'

  s.dependency 'ACPCoreBeta', '= 1.0.2beta2'
  s.dependency 'Branch'
end
