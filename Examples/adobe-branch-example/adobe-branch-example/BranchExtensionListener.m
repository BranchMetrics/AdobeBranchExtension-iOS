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
    
    NSString *eventName = [event eventName];
    
    if ([eventName isEqualToString: @"branch-init"]) {
        if (configuration[BRANCH_KEY_CONFIG]) {
            NSDictionary *launchOptions = @{};
            Branch *branchInstance = [Branch getInstance:configuration[@"branchKey"]];
            
            // TODO: Call collectLaunchInfo to get launch options
            [branchInstance setDebug];
            [branchInstance initSessionWithLaunchOptions:launchOptions
                                                 isReferrable:YES
                                   andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
                                       if ([[params objectForKey:@"+clicked_branch_link"] boolValue]) {
                                           NSDictionary* eventData = @{
                                                                       @"pictureName": @"glasses"
                                                                       };
                                           
                                           ACPExtensionEvent* initEvent = [ACPExtensionEvent extensionEventWithName:@"branch-deep-link-received"
                                                                                                               type:BRANCH_EVENT_TYPE_DEEP_LINK
                                                                                                             source:BRANCH_EVENT_SOURCE_STANDARD
                                                                                                               data:eventData
                                                                                                              error:&error];
                                           
                                           // TODO: See if we can add Branch deep link data to sharedShared state
                                           
                                           if ([ACPCore dispatchEvent:initEvent error:&error]) {
                                               NSLog(@"Error dispatching event %@:%ld", [error domain], [error code]);
                                           }
                                       }
                                   }];

        }
    }
}

@end
