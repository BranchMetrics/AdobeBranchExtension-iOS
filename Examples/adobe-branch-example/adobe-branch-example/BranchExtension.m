//
//  BranchExtension.m
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "BranchExtension.h"
#import "BranchExtensionListener.h"
#import <Branch/Branch.h>

@interface BranchExtension() {}
@property (strong, nullable) Branch *branchInstance;
@end

NSString *const branchEventTypeInit = @"com.branch.eventType.init";
NSString *const branchEventTypeCustom = @"com.branch.eventType.custom";
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
                             eventType:branchEventTypeInit
                           eventSource:branchEventSourceCustom
                                 error:&error]) {
            NSLog(@"BranchExtensionListener was registered");
        }
        else {
            NSLog(@"Error registering BranchExtensionListener: %@ %d", [error domain], (int)[error code]);
        }
        
        ADBExtensionEvent* initEvent = [ADBExtensionEvent extensionEventWithName:@"BRANCH_INIT"
                                                                            type:branchEventTypeInit
                                                                          source:branchEventSourceCustom
                                                                            data:nil
                                                                           error:&error];
        
        if (![self.api dispatchEvent:initEvent error:&error]) {
            NSLog(@"Error dispatching event %@:%ld", [error domain], [error code]);
        }
    }
    return self;
}

- (void) onUnregister {
    [super onUnregister];
}

@end
