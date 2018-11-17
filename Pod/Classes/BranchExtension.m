//
//  BranchExtension.m
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "BranchExtension.h"
#import "BranchExtensionListener.h"
#import "BranchExtensionRuleListener.h"
#import "BranchConfig.h"
#import <Branch/Branch.h>

@interface BranchExtension()
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
    self = [super init];
    if (!self) return self;

    // Turn logging on for now.
    BNCLogSetDisplayLevel(BNCLogLevelAll);

    NSError* error = nil;
    if ([self.api registerListener:[BranchExtensionListener class]
                         eventType:BRANCH_EVENT_TYPE_INIT
                       eventSource:BRANCH_EVENT_SOURCE_STANDARD
                             error:&error]) {
        BNCLog(@"BranchExtensionListener was registered.");
    } else {
        BNCLogError(@"Error registering BranchExtensionListener: %@.", error);
    }

    if ([self.api registerWildcardListener:[BranchExtensionRuleListener class] error:&error]) {
        BNCLog(@"BranchExtensionRuleListener was registered.");
    } else {
        BNCLogError(@"Can't register BranchExtensionRuleListener: %@.", error);
    }

    NSDictionary* eventData = @{
        @"initEventKey": @"initEventVal"
    };

    ACPExtensionEvent* initEvent =
        [ACPExtensionEvent extensionEventWithName:@"branch-init"
            type:BRANCH_EVENT_TYPE_INIT
            source:BRANCH_EVENT_SOURCE_STANDARD
            data:eventData
            error:&error];

    if (![self.api setSharedEventState:eventData event:initEvent error:&error]) {
        BNCLogError(@"Can't set shared state: %@.", error);
    }

    // ![self.api dispatchEvent:initEvent error:&error]
    if (![ACPCore dispatchEvent:initEvent error:&error]) {
        BNCLogError(@"Can't dispatch event %@.", error);
    }

    return self;
}

@end
