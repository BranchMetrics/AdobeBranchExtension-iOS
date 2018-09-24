//
//  BranchExtension.m
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "BranchExtension.h"
#import "BranchExtensionListener.h"
#import "BranchConfig.h"
#import <Branch/Branch.h>

@interface BranchExtension() {}
@property (strong, nullable) Branch *branchInstance;
@end

NSString *const branchEventTypeInit = @"com.branch.eventType.init";
NSString *const branchEventTypeCustom = @"com.branch.eventType.custom";
NSString *const branchEventSourceStandard = @"com.branch.eventSource.standard";
NSString *const branchEventSourceCustom = @"com.branch.eventSource.custom";

@implementation BranchExtension
- (nullable NSString*) name {
    return @"com.branch.extension";
}

- (nullable NSString*) version {
    return @"1.0.0"; // TODO: Read version number from package config instead
}

- (instancetype) init {
    if (self= [super init]) {
        NSError* error = nil;
        if ([self.api registerListener: [BranchExtensionListener class]
                             eventType:BRANCH_EVENT_TYPE_INIT
                           eventSource:BRANCH_EVENT_SOURCE_STANDARD
                                 error:&error]) {
            NSLog(@"BranchExtensionListener was registered");
        }
        else {
            NSLog(@"Error registering BranchExtensionListener: %@ %d", [error domain], (int)[error code]);
        }
        
        NSDictionary* eventData = @{
                    @"~state.com.branch.extension/deepLinkKey": @"pictureId",
                    @"com.branch.extension/deepLinkKey": @"pictureId",
                    @"~type": @"com.branch.eventType.init",
                    @"~source": @"com.branch.eventSource.standard",
                    @"deepLinkKey": @"pictureId"
        };
        
        ACPExtensionEvent* initEvent = [ACPExtensionEvent extensionEventWithName:@"branch-init"
                                                                            type:BRANCH_EVENT_TYPE_INIT
                                                                          source:BRANCH_EVENT_SOURCE_STANDARD
                                                                            data:eventData
                                                                           error:&error];
        
        if (![self.api setSharedEventState:eventData event:initEvent error:&error]) {
            NSLog(@"Error setting shared state %@:%ld", [error domain], [error code]);
        }
        
        // ![self.api dispatchEvent:initEvent error:&error]
        if ([ACPCore dispatchEvent:initEvent error:&error]) {
            NSLog(@"Error dispatching event %@:%ld", [error domain], [error code]);
        }
    }
    return self;
}

- (void) onUnregister {
    [super onUnregister];
}

@end
