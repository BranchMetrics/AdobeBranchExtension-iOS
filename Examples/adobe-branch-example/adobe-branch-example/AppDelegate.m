//
//  AppDelegate.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "AppDelegate.h"
#import <Branch/Branch.h>
#import "BranchExtension.h"
#import <ACPCore_iOS/ACPCore.h>
#import <ACPLifecycle_iOS/ACPLifecycle_iOS.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSError* error = nil;

    // Override point for customization after application launch.
    //[ADBMobileMarketing setLogLevel:ADBMobileLogLevelDebug];
    [ACPCore setLogLevel:ACPMobileLogLevelVerbose];

    // option 1 - access hosted Adobe config
    //[ADBMobileMarketing configureWithAppId:@"launch-ENe8e233db5c6a43628d097ba8125aeb26-development"];
    //[ACPCore configureWithAppId:@"launch-EN250ff13ac5814cb1a8750820b1f89b0a-development"];

    // option 2 - set config at runtime
    [self setupTestConfig];
    [ACPCore downloadRules];
    [ACPLifecycle registerExtension];
    
    [ACPCore lifecycleStart:nil];
    // [ADBMobileMarketing analyticsTrackAction:@"my v5 action" data:@{@"key1":@"value1"}];
    // [ACPCore registerExtension:[BranchExtension class] withName:@"com.branch.extension" withVersion:@"1.0.0" error:&error]
    if ([ACPCore registerExtension:[BranchExtension class] error:&error]) {
        NSLog(@"Branch SDK Registered");
    } else {
        NSLog(@"%@", error);
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app
        openURL:(NSURL *)url
        options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[Branch getInstance] application:app openURL:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application
        continueUserActivity:(NSUserActivity *)userActivity
        restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    [[Branch getInstance] continueUserActivity:userActivity];
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
