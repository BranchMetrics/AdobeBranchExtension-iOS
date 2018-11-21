//
//  BranchExtensionListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import <Branch/Branch.h>

@implementation AdobeBranchExtensionListener

+ (void) initialize {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(applicationLaunchNotification:)
        name:UIApplicationDidFinishLaunchingNotification
        object:nil];
}

static NSDictionary*bnc_launchOptions = nil;

+ (void) applicationLaunchNotification:(NSNotification*)notification {
    bnc_launchOptions = notification.userInfo;
}

- (void) hear:(ACPExtensionEvent*)event {
    BNCLog(@"Event: %@", event);
    if ([event.eventName isEqualToString: @"branch-init"])
        [self initializeEvent:event];
}

- (void) initializeEvent:(ACPExtensionEvent*)event {
    NSDictionary* configuration =
        [self.extension.api getSharedEventState:@"com.adobe.module.configuration" event:event error:nil];
    NSString*branchKey = configuration[BRANCH_KEY_CONFIG];
    if (branchKey.length <= 0) return;

    Branch*branchInstance = [Branch getInstance:branchKey];

    __weak __typeof(self) weak_self = self;
    NSDictionary *launchOptions = bnc_launchOptions ?: @{}; // TODO: Call collectLaunchInfo to get launch options
    [branchInstance initSessionWithLaunchOptions:launchOptions
        isReferrable:YES
        andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            __strong __typeof(weak_self) strong_self = weak_self;
            [strong_self handleDeepLinkParams:params error:error];
        }];
}

- (void) handleDeepLinkParams:(NSDictionary*)params error:(NSError*)error_ {
    if (![[params objectForKey:@"+clicked_branch_link"] boolValue])
        return;
    /*
    // TODO: Remove.
    NSDictionary* eventData = @{
        @"pictureName": @"glasses"
    };
    */
    BNCLogDebug(@"Received deep link: %@.", params);
    NSError*error = nil;
    ACPExtensionEvent* initEvent =
        [ACPExtensionEvent extensionEventWithName:@"branch-deep-link-received"
            type:BRANCH_EVENT_TYPE_DEEP_LINK
            source:BRANCH_EVENT_SOURCE_STANDARD
            data:params
            error:&error];

    // TODO: See if we can add Branch deep link data to sharedShared state
    if ([ACPCore dispatchEvent:initEvent error:&error]) {
       BNCLogError(@"Can't dispatch event: %@.", error);
    }
}

@end
