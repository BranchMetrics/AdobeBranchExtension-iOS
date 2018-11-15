Pod::Spec.new do |s|
  s.name             = "Adobe-Marketing-Branch"
  s.version          = "0.1.0"
  s.summary          = "Branch Integration for Analytics for iOS."

  s.description      = <<-DESC
                       Add the power of Branch deep linking and analytics to your Adobe Marketing Cloud.

                       With Branch's deep linking platform, mobile developers and marketers can leverage
                       their app content to improve discoverability and optimize install campaigns.

                       This is the Branch integration for the Adobe Marketing Cloud iOS library.
                       DESC

  s.homepage         = "https://github.com/BranchMetrics/adobe-branch-integration-ios"
  s.license          = 'MIT'
  s.author           = { "Branch Metrics" => "support@branch.io" }
  s.source           = { :git => "https://github.com/BranchMetrics/adobe-branch-integration-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/branchmetrics'

  s.platform         = :ios, '8.0'
  s.requires_arc     = true

  s.source_files     = 'Pod/Classes/**/*'

  s.dependency 'ACPCoreBeta'
  s.dependency 'Branch'
end
