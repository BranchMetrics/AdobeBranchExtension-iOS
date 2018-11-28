//
//  BranchExtension.h
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore_iOS/ACPCore_iOS.h>
@class Branch;

NS_ASSUME_NONNULL_BEGIN

///@brief Branch extension event names
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_NAME_INIT;
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_NAME_DEEP_LINK;

///@brief Branch extension event types
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_TYPE;
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_TYPE_DEEP_LINK;
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_TYPE_SHARE_SHEET;

///@brief Branch extension event names
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_NAME_INIT;

///@brief Branch extension event sources
FOUNDATION_EXPORT NSString* const BRANCH_EVENT_SOURCE_STANDARD;

///@brief Branch extension dictionary keys
FOUNDATION_EXPORT NSString* const BRANCH_KEY_CONFIG;

FOUNDATION_EXPORT NSString* const ABEBranchLinkTitleKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkSummaryKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkImageURLKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkCanonicalURLKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkUserInfoKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkCampaignKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkTagsKey;
FOUNDATION_EXPORT NSString* const ABEBranchLinkShareTextKey;

/**
 This is the class defines the root Adobe / Branch integration for deep linking and events.
 */
@interface AdobeBranchExtension : ACPExtension
/**
 @param deeplinkCallback    This is the deep link handler call back for your app. 
 */
+ (void) setDeepLinkCallback:(void (^_Nullable)(NSDictionary*_Nullable parameters, NSError*_Nullable error))deeplinkCallback;

+ (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity;

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

- (void) handleEvent:(ACPExtensionEvent*)event;

@property (strong, readonly, class) Branch*branch;
@end

NS_ASSUME_NONNULL_END
