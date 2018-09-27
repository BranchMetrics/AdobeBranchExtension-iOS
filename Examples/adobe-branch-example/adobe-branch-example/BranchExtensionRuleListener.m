//
//  BranchExtensionRuleListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "BranchExtensionRuleListener.h"
#import "BranchConfig.h"
#import <Branch/Branch.h>
#import "AppDelegate.h"
#import "ProductViewController.h"

@implementation BranchExtensionRuleListener

//po event.eventData
//{
//    triggeredconsequence =     {
//        detail =         {
//            campaign = tete;
//            channel = ete;
//            tags = tetete;
//        };
//        id = RCc140c5095d244b92b89f379a3c1b6e71;
//        type = "show-share-sheet";
//    };
//}

- (void) hear: (nonnull ACPExtensionEvent*) event {
    NSString *eventType = [event eventType];
    NSString *eventSource = [event eventSource];
    NSDictionary *eventData = [event eventData];
    NSDictionary *consequenceResult = [eventData objectForKey:@"triggeredconsequence"];
    NSString *consequenceType = [consequenceResult objectForKey:@"type"];
    NSDictionary *consequenceDetail = [consequenceResult objectForKey:@"detail"];
    // TODO: Add more secure check for Branch events in case someone tries to spoof Branch rules
    if ([eventType isEqualToString:@"com.adobe.eventType.rulesEngine"]) {
        if ([consequenceType isEqualToString:@"deep-link-route"]) {
            // TODO: Implement deep linking here
            NSString *deepLinkController = [consequenceDetail objectForKey:@"deepLinkController"];
            UINavigationController *navC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//            NSString *productName = [params objectForKey:@"productName"];
            NSString *productName = @"glasses";
            NSDictionary *params = @{@"productName":@"glasses"};
//            //UIViewController *nextVC;
            ProductViewController *nextVC;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            if (productName) {
                nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
                nextVC.productData = [NSDictionary dictionaryWithDictionary:params];
                [navC pushViewController:nextVC animated:YES];
            }
        } else if ([consequenceType isEqualToString:@"show-share-sheet"]) {
            // TODO: Add ability to use detail data only here
            BranchUniversalObject *buo = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:@"content/12345"];
            buo.title = @"My Content Title";
            buo.contentDescription = @"My Content Description";
            buo.imageUrl = @"https://lorempixel.com/400/400";
            buo.publiclyIndex = YES;
            buo.locallyIndex = YES;
            buo.contentMetadata.customMetadata[@"key1"] = @"value1";
    
            BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
            lp.feature = @"facebook";
            lp.channel = @"sharing";
            lp.campaign = @"content 123 launch";
            lp.stage = @"new user";
            lp.tags = @[@"one", @"two", @"three"];
    
            [lp addControlParam:@"$desktop_url" withValue: @"http://example.com/desktop"];
            [lp addControlParam:@"$ios_url" withValue: @"http://example.com/ios"];
            [lp addControlParam:@"$ipad_url" withValue: @"http://example.com/ios"];
            [lp addControlParam:@"$android_url" withValue: @"http://example.com/android"];
            [lp addControlParam:@"$match_duration" withValue: @"2000"];
    
            [lp addControlParam:@"custom_data" withValue: @"yes"];
            [lp addControlParam:@"look_at" withValue: @"this"];
            [lp addControlParam:@"nav_to" withValue: @"over here"];
            [lp addControlParam:@"random" withValue: [[NSUUID UUID] UUIDString]];
    
            [buo showShareSheetWithLinkProperties:lp andShareText:@"Super amazing thing I want to share!" fromViewController:nil completion:^(NSString* activityType, BOOL completed) {
                    NSLog(@"finished presenting");
                }];
        }
    }
}

// TODO: Implement and call in case above
- (void) showShareSheet: (nonnull NSDictionary*) data {
    
}

@end
