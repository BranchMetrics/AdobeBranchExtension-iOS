//
//  BranchExtensionListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "BranchExtension.h"
#import "BranchExtensionListener.h"
#import "BranchConfig.h"
#import <Branch/Branch.h>
#import "AppDelegate.h"
#import "ProductViewController.h"

@implementation BranchExtensionListener

- (void) hear: (nonnull ACPExtensionEvent*) event {
    NSDictionary* configuration = [self.extension.api getSharedEventState:@"com.adobe.module.configuration" event:event error:nil];
    
    NSDictionary* configurationMod = [self.extension.api getSharedEventState:@"com.branch.extension" event:event error:nil];
    
    NSString *eventName = [event eventName];
    
    if ([[event eventName]  isEqual: @"branch-init"]) {
        if (configuration[BRANCH_KEY_CONFIG]) {
            NSDictionary *launchOptions = @{};
            Branch *branchInstance = [Branch getInstance:configuration[@"branchKey"]];
            
            // TODO: Call collectLaunchInfo to get launch options
            
            [branchInstance setDebug];
            [branchInstance initSessionWithLaunchOptions:launchOptions
                                                 isReferrable:YES
                                   andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
                                       UINavigationController *navC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                                       NSString *productName = [params objectForKey:@"productName"];
                                       //UIViewController *nextVC;
                                       ProductViewController *nextVC;
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                       if (error) {
                                           NSLog(@"%@", error); // TODO: Figure out whether we actually want to log here
                                       } else if (productName) {
                                           nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
                                           nextVC.productData = [NSDictionary dictionaryWithDictionary:params];
                                           //[navC setViewControllers:@[nextVC] animated:YES];
                                           [navC pushViewController:nextVC animated:YES];
                                       }
//                                       else {
//                                           nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//                                       }
                                   }];
        }
        
//        ADBExtensionEvent* initEvent = [ADBExtensionEvent extensionEventWithName:@"BRANCH_INIT"
//                                                                            type:branchEventTypeInit
//                                                                          source:branchEventSourceStandard
//                                                                            data:nil
//                                                                           error:&error];
//
//        if (![self.api dispatchEvent:initEvent error:&error]) {
//            NSLog(@"Error dispatching event %@:%ld", [error domain], [error code]);
//        }
    }
//    else if ([[event eventName] isEqual: @"branch-share-sheet"]) {
//        BranchUniversalObject *buo = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:@"content/12345"];
//        buo.title = @"My Content Title";
//        buo.contentDescription = @"My Content Description";
//        buo.imageUrl = @"https://lorempixel.com/400/400";
//        buo.publiclyIndex = YES;
//        buo.locallyIndex = YES;
//        buo.contentMetadata.customMetadata[@"key1"] = @"value1";
//
//        BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
//        lp.feature = @"facebook";
//        lp.channel = @"sharing";
//        lp.campaign = @"content 123 launch";
//        lp.stage = @"new user";
//        lp.tags = @[@"one", @"two", @"three"];
//
//        [lp addControlParam:@"$desktop_url" withValue: @"http://example.com/desktop"];
//        [lp addControlParam:@"$ios_url" withValue: @"http://example.com/ios"];
//        [lp addControlParam:@"$ipad_url" withValue: @"http://example.com/ios"];
//        [lp addControlParam:@"$android_url" withValue: @"http://example.com/android"];
//        [lp addControlParam:@"$match_duration" withValue: @"2000"];
//
//        [lp addControlParam:@"custom_data" withValue: @"yes"];
//        [lp addControlParam:@"look_at" withValue: @"this"];
//        [lp addControlParam:@"nav_to" withValue: @"over here"];
//        [lp addControlParam:@"random" withValue: [[NSUUID UUID] UUIDString]];
//
//        [buo showShareSheetWithLinkProperties:lp andShareText:@"Super amazing thing I want to share!" fromViewController:nil completion:^(NSString* activityType, BOOL completed) {
//                NSLog(@"finished presenting");
//            }];
//    }
}

@end
