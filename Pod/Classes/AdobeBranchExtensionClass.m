//
//  BranchExtension.m
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import <Branch/Branch.h>

NSString *const branchEventTypeInit = @"com.branch.eventType.init";
NSString *const branchEventTypeCustom = @"com.branch.eventType.custom";
NSString *const branchEventSourceStandard = @"com.branch.eventSource.standard";
NSString *const branchEventSourceCustom = @"com.branch.eventSource.custom";

NSString *const BRANCH_KEY_CONFIG               = @"branchKey";
NSString *const BRANCH_EVENT_TYPE               = @"com.branch.eventType";
NSString *const BRANCH_EVENT_TYPE_INIT          = @"com.branch.eventType.init";
NSString *const BRANCH_EVENT_TYPE_DEEP_LINK     = @"com.branch.eventType.deepLink";
NSString *const BRANCH_EVENT_TYPE_SHARE_SHEET   = @"com.branch.eventType.shareSheet";
NSString *const BRANCH_EVENT_TYPE_CONSTANT      = @"com.branch.eventType.custom";
NSString *const BRANCH_EVENT_SOURCE_STANDARD    = @"com.branch.eventSource.standard";
NSString *const BRANCH_EVENT_SOURCE_CUSTOM      = @"com.branch.eventSource.custom";

#pragma mark - AdobeBranchExtension

@interface AdobeBranchExtension()
@end

@implementation AdobeBranchExtension

static void (^bnc_deepLinkCallback)(NSDictionary*, NSError*) = nil;
static Branch*bnc_branchInstance = nil;

+ (void) setDeepLinkCallback:(void (^_Nullable)(NSDictionary*_Nullable, NSError*_Nullable))deeplinkCallback {
    bnc_deepLinkCallback = deeplinkCallback;
}

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
    if ([self.api registerListener:[AdobeBranchExtensionListener class]
                         eventType:BRANCH_EVENT_TYPE_INIT
                       eventSource:BRANCH_EVENT_SOURCE_STANDARD
                             error:&error]) {
        BNCLogDebug(@"BranchExtensionListener was registered.");
    } else {
        BNCLogError(@"Error registering AdobeBranchExtensionListener: %@.", error);
    }

    if ([self.api registerWildcardListener:[BranchExtensionRuleListener class] error:&error]) {
        BNCLog(@"BranchExtensionRuleListener was registered.");
    } else {
        BNCLogError(@"Can't register AdobeBranchExtensionRuleListener: %@.", error);
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

+ (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    return [bnc_branchInstance continueUserActivity:userActivity];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [bnc_branchInstance application:application openURL:url options:options];
}

@end
