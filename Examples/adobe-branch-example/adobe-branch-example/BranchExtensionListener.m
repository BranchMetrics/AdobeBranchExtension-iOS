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
}

@end
