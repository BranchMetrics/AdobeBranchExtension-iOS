//
//  BranchExtension.h
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore_iOS/ACPCore_iOS.h>
@class Branch;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString*const BranchEventTypeInit;

FOUNDATION_EXPORT NSString* const BRANCH_KEY_CONFIG;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_TYPE;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_TYPE_INIT;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_TYPE_DEEP_LINK;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_TYPE_SHARE_SHEET;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_TYPE_CONSTANT;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_SOURCE_STANDARD;
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_SOURCE_CUSTOM;

@interface AdobeBranchExtension : ACPExtension

/**
 @param deeplinkCallback    This is the deep link handler call back for your app. 
 */
+ (void) setDeepLinkCallback:(void (^_Nullable)(NSDictionary*_Nullable parameters, NSError*_Nullable error))deeplinkCallback;

+ (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity;

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

@property (strong, readonly, class) Branch*branch;
@end

NS_ASSUME_NONNULL_END

