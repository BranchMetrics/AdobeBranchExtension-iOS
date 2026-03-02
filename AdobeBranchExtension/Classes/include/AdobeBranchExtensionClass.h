//
//  BranchExtension.h
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BranchSDK/Branch.h>
@import AEPCore;

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Branch extension event names
*/

/// Branch extension event type
FOUNDATION_EXPORT NSString*const ABEBranchEventType;

/// Branch extension event source
FOUNDATION_EXPORT NSString*const ABEBranchEventSource;

/// Branch extension error code
typedef NS_ENUM(NSInteger, ABEBranchErrorCode) {
    ABEBranchConflictConfiguration  = 2000,
};

/**
 This is the class defines the root Adobe / Branch integration for deep linking and events.
 */
@interface AdobeBranchExtension : NSObject <AEPExtension>

+ (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(callbackWithParams)callback;

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity;

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

+ (void)configureEventTypes:(nullable NSArray<NSString *> *)eventTypes andEventSources:(nullable NSArray<NSString *> *)eventSources;

+ (BOOL)configureEventExclusionList:(nullable NSArray<NSString *> *)eventNames error:(NSError * __autoreleasing *)configError;

+ (BOOL)configureEventAllowList:(nullable NSArray<NSString *> *)eventNames error:(NSError * __autoreleasing *)configError;

- (void)handleEvent:(AEPEvent*)event;

@end

NS_ASSUME_NONNULL_END
