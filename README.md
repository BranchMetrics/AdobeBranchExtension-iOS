[![Version](https://img.shields.io/cocoapods/v/AdobeBranchExtension.svg?style=flat)](https://cocoapods.org/pods/AdobeBranchExtension)
[![License](https://img.shields.io/cocoapods/l/AdobeBranchExtension.svg?style=flat)](https://cocoapods.org/pods/AdobeBranchExtension)
[![Platform](https://img.shields.io/cocoapods/p/AdobeBranchExtension.svg?style=flat)](https://cocoapods.org/pods/AdobeBranchExtension)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


![Branch Logo](scripts/images/branch-75.png)

# AdobeBranchExtension

Add the power of Branch deep linking and attribute to your Adobe Marketing Cloud app. With Branch's linking platform, mobile developers and marketers can grow their mobile business with world class deep linking and attribution.

## Features
1. All events tracked with the Adobe SDK will automatically be sent to Branch without any extra work
2. All core Branch functionality is accessible

## Requirements
- iOS 10
- Adobe Core Platform
- Branch SDK

## Example

An example app can be found in the AdobeBranchExtension-iOS repository, in the `Examples/AdobeBranchExample`
project.

- [AdobeBranchExample Project](https://github.com/BranchMetrics/AdobeBranchExtension-iOS/tree/master/Examples/AdobeBranchExample)
- [AdobeBranchExtension-iOS Repository](https://github.com/BranchMetrics/AdobeBranchExtension-iOS)

## Installation & Usage

Here's a brief outline of how to use the AdobeBranchExtension in your app:

1. You'll need to configure your app and get a Branch API key in the [Branch Metrics dashboard](https://branch.dashboard.branch.io/account-settings/app). You can read more about configuring your dashboard in the Branch docs here.

2. For deep linking, you'll need to add associated domains for universal links as described in the Branch docs here:

   - [Configure associated domains](https://docs.branch.io/pages/apps/ios/#configure-associated-domains)
   - [Configure entitlements](https://docs.branch.io/pages/apps/ios/#configure-entitlements)

3. Also add an app URI scheme and your Branch key to the plist file for you app for deep linking.

   - [Configure your Info.plist with Branch key and for URI schemes](https://docs.branch.io/pages/apps/ios/#configure-infoplist)

4. In the Adobe dashboard, activate Branch and add your Branch key to your app's configuration.

   Activate Branch:

   ![Activate Branch](scripts/images/adobe-dash-install.png)

5. Add the AdobeBranchExtension to your app's Podfile.

        pod 'AdobeBranchExtension'

6. Run `pod install` and `pod update` do install the latest version of the extension.
7. Register the Branch `AdobeBranchExtension` with `ACPCore` in `didFinishLaunchingWithOptions`:

```
    #import <AdobeBranchExtension/AdobeBranchExtension.h>
    ...
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    [ACPCore registerExtension:[AdobeBranchExtension class] error:&error]


    ...
    return YES; // Important! If you return `NO` iOS will not handle deep linking as expected.
}
```

8. Add the Branch deep link routers and receivers in your AppDelegate class in three places as shown below. You can see some [best practices on deep link routing in this doc](https://docs.branch.io/pages/deep-linking/routing/).

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Up here you register your AdobeBranchExtension with ACPCore
    
    // Handle your Branch deep link routing in the callback
    [AdobeBranchExtension initSessionWithLaunchOptions:launchOptions
                            andRegisterDeepLinkHandler:^(NSDictionary * _Nullable params, NSError * _Nullable error) {
        if (!error && params && [params[@"+clicked_branch_link"] boolValue]) {

//            EXAMPLE ROUTING CODE
//            Product*product = Product.new;
//            product.name        = params[@"$og_title"];
//            product.summary     = params[@"$og_description"];
//            product.URL         = params[@"$canonical_url"];
//            product.imageName   = params[@"image_name];
//            product.imageURL    = params[@"$og_image_url"];
//            
//            ProductViewController *pvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductViewController"];
//            pvc.title = product.name;
//            pvc.product = product;
//            [((UINavigationController *)self.window.rootViewController) pushViewController:pvc animated:YES];

        }
    }];
}

- (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url
        options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [AdobeBranchExtension application:application openURL:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application
        continueUserActivity:(NSUserActivity *)userActivity
        restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    [AdobeBranchExtension application:application continueUserActivity:userActivity];
    return YES;
}
```


Congratulations! With those seven quick and easy steps you've installed and activated the AdobeBranchExtension.

## Implementing Branch Features

Once you've added the AdobeBranchExtension and Branch, you can always use Branch features directly. You can learn about using the Branch features here, in the Branch documentation for iOS.](https://docs.branch.io/pages/apps/ios/)


### Automatic: Track Action and State
When you track actions and state in Adobe Launch, the action and state messages are sent to Branch too and shown on the
Branch dashboards. This allows you to track the effectiveness of deep link campaigns and viral sharing in your app's actions.

Here's an example of tracking app state via Adobe Launch:

    [ACPCore trackState:@"VIEW" data:@{
        @"name":        self.product.name,
        @"revenue":     @"200.0",
        @"currency":    @"USD"
    }];

You can also customize which event types and sources are shared with Branch.  Providing empty lists, disables sharing.

    [AdobeBranchExtension configureEventTypes:@[ @"com.adobe.eventType.generic.track" ] andEventSources:@[ @"com.adobe.eventSource.requestContent" ];

## License

AdobeBranchExtension is available under the MIT license. See the LICENSE file for more info.

## Developer Resources

- [Branch Documentation](https://docs.branch.io/)
- [Branch Dashboard](https://dashboard.branch.io/)
- [Adobe Mobile SDK V5](https://launch.gitbook.io/marketing-mobile-sdk-v5-by-adobe-documentation/release-notes)
- [Adobe Branch Mobile Extension UI Plugin](https://github.com/BranchMetrics/adobe-branch-mobile-plugin)
- [Adobe Mobile SDK V5 Docs](https://launch.gitbook.io/marketing-mobile-sdk-v5-by-adobe-documentation/build-your-own-extension)
