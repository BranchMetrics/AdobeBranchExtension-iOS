//
//  BranchExtension.h
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore_iOS/ACPCore_iOS.h>
@class Branch;

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Branch extension event names
*/

/// Initialize the Adobe Branch extension.
FOUNDATION_EXPORT NSString*const ABEBranchEventNameInitialize;

/// Branch opened a deep link with the link parameters in `eventData` with the ABEBranchLink keys.
FOUNDATION_EXPORT NSString*const ABEBranchEventNameDeepLinkOpened;
FOUNDATION_EXPORT NSString*const BRANCH_EVENT_NAME_DEEP_LINK;

/// Show a share sheet with the link parameters as specified by the keys in the ABEBranchLink keys.
FOUNDATION_EXPORT NSString*const ABEBranchEventNameShowShareSheet;

/// Branch extension event type
FOUNDATION_EXPORT NSString*const ABEBranchEventType;

/// Branch extension event source
FOUNDATION_EXPORT NSString*const ABEBranchEventSource;

/// Branch deep link keys
FOUNDATION_EXPORT NSString*const ABEBranchLinkTitleKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkSummaryKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkImageURLKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkCanonicalURLKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkUserInfoKey;      //!< Accepts a dictionary of key/values.
FOUNDATION_EXPORT NSString*const ABEBranchLinkCampaignKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkTagsKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkShareTextKey;
FOUNDATION_EXPORT NSString*const ABEBranchLinkIsFirstSessionKey;

FOUNDATION_EXPORT NSString*const ABEBranchDeepLinkNotification;

/**
 This is the class defines the root Adobe / Branch integration for deep linking and events.
 */
@interface AdobeBranchExtension : ACPExtension

+ (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity;

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

- (void) handleEvent:(ACPExtensionEvent*)event;

@property (strong, readonly, class) Branch*branch;
@end

NS_ASSUME_NONNULL_END
