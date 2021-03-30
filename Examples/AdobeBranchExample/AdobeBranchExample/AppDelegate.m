//
//  AppDelegate.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import "AppDelegate.h"

#import "ACPCore.h"
#import "ACPAnalytics.h"
#import <ACPCore/ACPIdentity.h>
#import <ACPCore/ACPLifecycle.h>
#import "ACPSignal.h"
#import "ACPUserProfile.h"

#import "ProductViewController.h"
#import "AdobeBranchExtension.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSError* error = nil;
    // Override point for customization after application launch.
    [ACPCore setLogLevel:ACPMobileLogLevelError];
//    [ACPCore setLogLevel:ACPMobileLogLevelVerbose];
//    [ACPAnalytics setVisitorIdentifier:@"custom_identifier_bb"];// for testing passAdobeIdsToBranch method

    // register ACPCore
    if ((YES)) {
        // option 1 - access hosted Adobe config
        //[ADBMobileMarketing configureWithAppId:@"launch-ENe8e233db5c6a43628d097ba8125aeb26-development"];
//        [ACPCore configureWithAppId:@"launch-EN250ff13ac5814cb1a8750820b1f89b0a-development"];
        [ACPCore configureWithAppId:@"d10f76259195/c769149ebd48/launch-f972d1367b58-development"];//Adobe Launch property: "iOS Test"
    } else {
        // option 2 - set config at runtime
        [self setupTestConfig];
    }
    
    // register extensions (for Adobe Launch property: "iOS Test")
    [ACPAnalytics registerExtension];
    [ACPIdentity registerExtension];
    [ACPLifecycle registerExtension];
    
    // Define the exclusion list of the events names
    [AdobeBranchExtension configureEventExclusionList:@[@"VIEW"]];
    // register AdobeBranchExtension
    if ([ACPCore registerExtension:[AdobeBranchExtension class] error:&error]) {
        NSLog(@"AdobeBranchExtension Registered");
    } else {
        NSLog(@"%@", error);
    }
    
    // start Adobe SDK & extensions
    [ACPCore lifecycleStart:nil];
    [ACPCore start:nil];
    
    // Disable event sharing
    //[AdobeBranchExtension configureEventTypes:nil andEventSources:nil];
    
    // initialize Branch session, [AdobeBranchExtension initSessionWithLaunchOptions] is different from
    // [[Branch getInstance] initSessionWithLaunchOptions] in that it holds up initialization in order to collect
    // Adobe IDs and pass them to Branch as request metadata, see [AdobeBranchExtension delayInitSessionToCollectAdobeIDs]
    [[Branch getInstance] enableLogging];
    [AdobeBranchExtension initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary * _Nullable params, NSError * _Nullable error) {
        if (!error && params && [params[@"+clicked_branch_link"] boolValue]) {

            Product*product = Product.new;
            product.name        = params[@"$og_title"];
            product.summary     = params[@"$og_description"];
            product.URL         = params[@"$canonical_url"];
            product.imageName   = params[@"image_name"];
            product.imageURL    = params[@"$og_image_url"];
            
            ProductViewController *pvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductViewController"];
            pvc.title = product.name;
            pvc.product = product;
            [((UINavigationController *)self.window.rootViewController) pushViewController:pvc animated:YES];
        }
    }];
    
    return YES;
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

- (void) setupTestConfig {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    
    // ============================================================
    // global
    // ============================================================
    config[@"global.privacy"] = @"optedin";
    config[@"global.ssl"] = @true;
    
    // ============================================================
    // Branch
    // ============================================================
    config[@"branchKey"] = @"key_live_nbB0KZ4UGOKaHEWCjQI2ThncEAeRJmhy";
    
    // ============================================================
    // acquisition
    // ============================================================
    config[@"acquisition.appid"] = @"";
    config[@"acquisition.server"] = @"";
    config[@"acquisition.timeout"] = @0;
    
    // ============================================================
    // analytics
    // ============================================================
    config[@"analytics.aamForwardingEnabled"] = @false;
    config[@"analytics.batchLimit"] = @0;
    config[@"analytics.offlineEnabled"] = @true;
    config[@"analytics.rsids"] = @"";
    config[@"analytics.server"] = @"";
    config[@"analytics.referrerTimeout"] = @0;
    
    // ============================================================
    // audience manager
    // ============================================================
    config[@"audience.server"] = @"";
    config[@"audience.timeout"] = @0;
    
    // ============================================================
    // identity
    // ============================================================
    config[@"experienceCloud.server"] = @"";
    config[@"experienceCloud.org"] = @"";
    config[@"identity.adidEnabled"] = @false;
    
    // ============================================================
    // target
    // ============================================================
    config[@"target.clientCode"] = @"";
    config[@"target.timeout"] = @0;
    
    // ============================================================
    // lifecycle
    // ============================================================
    config[@"lifecycle.sessionTimeout"] = @0;
    config[@"lifecycle.backdateSessionInfo"] = @false;
    
    // ============================================================
    // rules engine
    // ============================================================
    // config[@"rules.url"] = @"https://assets.adobedtm.com/staging/launch-EN9ec4c2c17eab4160bea9480945cdeb4d-development-rules.zip";
    config[@"rules.url"] = @"https://assets.adobedtm.com/staging/launch-EN23ef0b4732004b088acea70c57a44fe2-development-rules.zip";
    config[@"com.branch.extension/deepLinkKey"] = @"pictureId";
    config[@"deepLinkKey"] = @"pictureId";
    
    //[ADBMobileMarketing updateConfiguration:config];
    [ACPCore updateConfiguration:config];
}

@end
