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
#import <Branch/BNCThreads.h>
#import "AppDelegate.h"
#import "ProductViewController.h"
#import "AppDelegate.h"
#import "Product.h"

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

- (void) showConsequenceDeepLinkRoute:(NSDictionary*)detail {
    // TODO: Implement deep linking here
    NSLog(@"Deep link routed: %@.", detail);
/*
//  NSString *deepLinkController = [consequenceDetail objectForKey:@"deepLinkController"];

    UINavigationController *navigationController =
        (id) [UIApplication sharedApplication].delegate.window.rootViewController;


    //            NSString *productName = [params objectForKey:@"productName"];
    NSString *productName = @"glasses";
    NSDictionary *params = @{@"productName":@"glasses"};
    //            //UIViewController *nextVC;
    ProductViewController *nextVC;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (productName) {
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
        nextVC.product = Product.new;
        nextVC.product.name =
        [navigationController pushViewController:nextVC animated:YES];
        //[navC setViewControllers:@[nextVC] animated:YES];
        //[navC pushViewController:nextVC animated:NO];
    }
*/
}

- (void) hear:(ACPExtensionEvent*)event {
    NSString *eventType = [event eventType];
    if (![eventType isEqualToString:@"com.adobe.eventType.rulesEngine"])
        return;

//  NSString *eventSource = [event eventSource];

    NSDictionary*consequence = event.eventData[@"triggeredconsequence"];
    NSString*type = consequence[@"type"];
    NSDictionary*detail = consequence[@"detail"];

    // TODO: Add more secure check for Branch events in case someone tries to spoof Branch rules ??

    if ([type isEqualToString:@"deep-link-route"]) {
        BNCPerformBlockOnMainThreadAsync(^{
            [self showConsequenceDeepLinkRoute:detail];
        });
    } else
    if ([type isEqualToString:@"show-share-sheet"]) {
        BNCPerformBlockOnMainThreadAsync(^ {
            [self showShareSheet:detail];
        });
    }
}

- (void) showShareSheet:(NSDictionary*)data {
    /*
    *Adobe Fields*

    campaign = share;
    contentDescription = MyContent;
    contentImage = "https://cdn.branch.io/branch-assets/1538165719615-og_image.jpeg";
    contentTitle = BranchGlasses;
    shareText = MyDemoShareText;
    tags = tag;
    */

    BranchUniversalObject *buo = BranchUniversalObject.new;
    buo.title = data[@"contentTitle"];
    buo.canonicalIdentifier = data[@"canonicalIdentifier"];
    if (buo.title.length == 0 && buo.canonicalIdentifier.length == 0) {
        BNCLogError(@"Canonical ID or title must be set for Branch Universal Objects");
        return;
    }
    buo.contentDescription = data[@"contentDescription"];
    buo.imageUrl = data[@"contentImage"];
    buo.locallyIndex = YES;

    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.campaign = data[@"campaign"];
    NSArray*tags = data[@"tags"];
    if ([tags isKindOfClass:NSString.class]) {
        tags = @[ tags ];
    }
    if ([tags isKindOfClass:NSArray.class]) {
        lp.tags = tags;
    }

    BranchShareLink*shareLink =
        [[BranchShareLink alloc] initWithUniversalObject:buo linkProperties:lp];
    shareLink.title = buo.title ?: @"";
    shareLink.shareText = data[@"shareText"] ?: @"";
    [shareLink presentActivityViewControllerFromViewController:nil anchor:nil];
}

@end
