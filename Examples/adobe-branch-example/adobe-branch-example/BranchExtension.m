//
//  BranchExtension.m
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "BranchExtension.h"
#import <Branch/Branch.h>

@interface BranchExtension() {}
@property (strong, nullable) Branch *branchInstance;
@end

NSString *const branchEventType = @"com.branch.eventType.custom";
NSString *const branchEventSource = @"com.branch.eventSource.custom";

@implementation BranchExtension
- (nullable NSString*) name {
    return @"com.branch.extension";
}

- (nullable NSString*) version {
    return @"1.0.0"; // TODO: Read version number from package config instead
}

- (instancetype) init {
    if (self= [super init]) {
        NSLog(@"INIT BRANCH"); // TODO: Remove this log when done
        
        NSError* error = nil;
        NSDictionary *launchOptions = @{};
        NSString *branchkey = @"key_live_nbB0KZ4UGOKaHEWCjQI2ThncEAeRJmhy"; // TODO: Fill this in with settings from the Adobe Extension UI
        self.branchInstance = [Branch getInstance:branchkey];
        [self.branchInstance setDebug]; // TODO: Remove this line when done. Check if we want to give them the option to enable through shim
        [self.branchInstance initSessionWithLaunchOptions:launchOptions
                                             isReferrable:YES
                               andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
                                   ADBExtensionEvent* initEvent = [ADBExtensionEvent extensionEventWithName:@"branch_extension_install"
                                                                                                       type:branchEventType
                                                                                                     source:branchEventSource
                                                                                                       data:params
                                                                                                      error:&error];
                                   if (error) {
                                       NSLog(@"%@", error); // TODO: Figure out whether we actually want to log here
                                       return;
                                   }
                                   if (![self.api dispatchEvent:initEvent error:&error]) {
                                       NSLog(@"%@", error); // TODO: Figure out whether we actually want to log here
                                   }
                               }];
    }
    return self;
}

- (void) onUnregister {
    [super onUnregister];
}

@end
