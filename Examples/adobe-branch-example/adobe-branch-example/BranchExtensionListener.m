//
//  BranchExtensionListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "BranchExtension.h"
#import "BranchExtensionListener.h"
#import <Branch/Branch.h>


@implementation BranchExtensionListener

- (void) hear: (nonnull ADBExtensionEvent*) event {
    NSDictionary* configuration = [self.extension.api getSharedEventState:@"com.adobe.module.configuration" event:event error:nil];
    
    if ([[event eventName]  isEqual: @"BRANCH_INIT"]) {
        if (configuration[@"branchKey"]) {
            NSDictionary *launchOptions = @{};
            Branch *branchInstance = [Branch getInstance:configuration[@"branchKey"]];
            
            [branchInstance setDebug];
            [branchInstance initSessionWithLaunchOptions:launchOptions
                                                 isReferrable:YES
                                   andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
                                       NSString *pictureId = [params objectForKey:@"pictureId"];
                                       UIViewController *nextVC;
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                       if (error) {
                                           NSLog(@"%@", error); // TODO: Figure out whether we actually want to log here
                                       } else if (pictureId) {
                                           nextVC = [storyboard instantiateViewControllerWithIdentifier:@"PicVC"];
                                           [nextVC setNextPictureId:pictureId];
                                       } else {
                                           nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
                                       }
                                   }];
//            ExampleDeepLinkingController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DeepLinkingController"];
//
//            [branchInstance registerDeepLinkController:controller forKey:@"product_picture" withPresentation:BNCViewControllerOptionShow];
//            [branchInstance initSessionWithLaunchOptions:launchOptions automaticallyDisplayDeepLinkController:YES];
        }
    }
}

@end
