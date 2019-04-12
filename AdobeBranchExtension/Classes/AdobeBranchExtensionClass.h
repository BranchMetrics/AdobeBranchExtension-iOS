//
//  BranchExtension.h
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Branch/Branch.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Branch extension event names
*/

/// Branch extension event type
FOUNDATION_EXPORT NSString*const ABEBranchEventType;

/// Branch extension event source
FOUNDATION_EXPORT NSString*const ABEBranchEventSource;

/**
 This is the class defines the root Adobe / Branch integration for deep linking and events.
 */
@interface AdobeBranchExtension : ACPExtension

+ (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(callbackWithParams)callback;

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity;

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

+ (void)configureEventTypes:(nullable NSArray<NSString *> *)eventTypes andEventSources:(nullable NSArray<NSString *> *)eventSources;

- (void)handleEvent:(ACPExtensionEvent*)event;

@end

NS_ASSUME_NONNULL_END
