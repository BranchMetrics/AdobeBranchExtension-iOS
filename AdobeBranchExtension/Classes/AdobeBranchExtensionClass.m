//
//  BranchExtension.m
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import "AdobeBranchExtensionConfig.h"

#if __has_include(<BranchSDK/Branch.h>)
    #import <BranchSDK/Branch.h> // Keep CocoaPods/Old SPM happy
#else
    #import "Branch.h" // Fallback for strict SPM environments
#endif


#if __has_include(<BranchSDK/BranchLogger.h>)
    #import <BranchSDK/BranchLogger.h>
#else
    #import "BranchLogger.h"
#endif


#if __has_include(<BranchSDK/BranchPluginSupport.h>)
    #import <BranchSDK/BranchPluginSupport.h>
#else
    #import "BranchPluginSupport.h"
#endif


#if __has_include(<BranchSDK/BranchEvent.h>)
    #import <BranchSDK/BranchEvent.h>
#else
    #import "BranchEvent.h"
#endif


@import AEPCore;
@import AEPEdge;
@import AEPEdgeIdentity;

#pragma mark Constants

// Branch events type and source
NSString*const ABEBranchEventType               = @"com.branch.eventType";
NSString*const ABEBranchEventSource             = @"com.branch.eventSource";

// Adobe Launch Branch extension error domain
NSString*const AdobeBranchExtensionErrorDomain  = @"io.branch.adobe_launch_extension.error";

// 1. events of this type and source
NSString *const ABEAdobeHubEventType = @"com.adobe.eventType.hub";
NSString *const ABEAdobeSharedStateEventSource = @"com.adobe.eventSource.sharedState";
// 2. whose owner (i.e. extension/module) retrieved with this key from event data
NSString *const ABEAdobeEventDataKey_StateOwner = @"stateowner";
// 3. is either
NSString *const ABEAdobeIdentityExtension = @"com.adobe.edge.identity";
NSString *const ABEAdobeAnalyticsExtension = @"com.adobe.module.analytics";
// 4. will contain Adobe ID values needed to be passed to Branch prior to session initialization

NSString *const EXPERIENCE_CLOUD_ID_KEY = @"ECID";

@interface AdobeBranchExtension()
@end

@implementation AdobeBranchExtension {
    id<AEPExtensionRuntime> runtime_;
}

#pragma mark - Extension Protocol Methods

- (NSString *)name {
    return @"io.branch.adobe.extension";
}

- (NSString *)friendlyName {
    return @"AdobeBranchExtension";
}

+ (NSString * _Nonnull)extensionVersion {
    return ADOBE_BRANCH_VERSION;
}

- (NSDictionary<NSString *,NSString *> *)metadata {
    return nil;
}

- (id<AEPExtensionRuntime>)runtime {
    return runtime_;
}

- (nullable instancetype)initWithRuntime:(id<AEPExtensionRuntime> _Nonnull)runtime {
    self = [super init];
    
    runtime_ = runtime;
    return self;
}

- (void)onRegistered {
    [[BranchLogger shared] logDebug:@"AdobeBranchExtension listener registered" error:nil];
    
    [self deviceDataSharedState: NULL];
    
    [runtime_ registerListenerWithType:AEPEventType.wildcard source:AEPEventSource.wildcard listener:^(AEPEvent * _Nonnull event) {
        [self handleEvent:event];
    }];
}

- (void)onUnregistered {}

- (BOOL)readyForEvent:(AEPEvent * _Nonnull)event {
    AEPSharedStateResult *result = [runtime_ getSharedStateWithExtensionName:self.name event:event barrier:NO];
    if (!result) {
        return false;
    }
    
    return result.status == AEPSharedStateStatusSet;
}

#pragma mark - Branch Methods

+ (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(callbackWithParams)callback {
    [self delayInitSessionToCollectAdobeIDs];
    [[Branch getInstance] registerPluginName:@"AdobeBranchExtension" version:ADOBE_BRANCH_VERSION];
    [[Branch getInstance] initSessionWithLaunchOptions:options andRegisterDeepLinkHandler:callback];
}

+ (void) delayInitSessionToCollectAdobeIDs {
    [[Branch getInstance] dispatchToIsolationQueue:^{
        // we use semaphore to block Branch session initialization thread for 1 seconds
        // because it takes a couple hundred milliseconds to capture Adobe IDs and pass them
        // to Branch as request metadata
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    return [[Branch getInstance] continueUserActivity:userActivity];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [[Branch getInstance] application:application openURL:url options:options];
}

+ (void)configureEventTypes:(nullable NSArray<NSString *> *)eventTypes andEventSources:(nullable NSArray<NSString *> *)eventSources {
    if (eventTypes) {
        [AdobeBranchExtensionConfig instance].eventTypes = eventTypes;
    } else {
        [AdobeBranchExtensionConfig instance].eventTypes = @[];
    }
    
    if (eventSources) {
        [AdobeBranchExtensionConfig instance].eventSources = eventSources;
    } else {
        [AdobeBranchExtensionConfig instance].eventSources = @[];
    }
}

+ (BOOL)configureEventExclusionList:(nullable NSArray<NSString *> *)eventNames error:(NSError * __autoreleasing *)configError {
    if (eventNames) {
        // If already configured allowList
        if ([AdobeBranchExtensionConfig instance].allowList.count != 0) {
            *configError = [NSError errorWithDomain:AdobeBranchExtensionErrorDomain code:ABEBranchConflictConfiguration userInfo:@{NSLocalizedFailureReasonErrorKey: @"Already configured allowList for AdobeBranchExtensionConfig"}];
            [[BranchLogger shared] logWarning:[NSString stringWithFormat:@"AdobeBranchExtensionConfig error: %@.", *configError] error:*configError];
            return NO;
        } else {
            [AdobeBranchExtensionConfig instance].exclusionList = eventNames;
        }
    }
    return YES;
}

+ (BOOL)configureEventAllowList:(nullable NSArray<NSString *> *)eventNames error:(NSError * __autoreleasing *)configError {
    if (eventNames) {
        // If already configured allowList
        if ([AdobeBranchExtensionConfig instance].exclusionList.count != 0) {
            *configError = [NSError errorWithDomain:AdobeBranchExtensionErrorDomain code:ABEBranchConflictConfiguration userInfo:@{NSLocalizedFailureReasonErrorKey: @"Already configured exclusionList for AdobeBranchExtensionConfig"}];
            [[BranchLogger shared] logWarning:[NSString stringWithFormat:@"AdobeBranchExtensionConfig error: %@.", *configError] error:*configError];
            return NO;
        } else {
            [AdobeBranchExtensionConfig instance].allowList = eventNames;
        }
    }
    return YES;
}

#pragma mark - Action Events

- (void)handleEvent:(AEPEvent*)event {
    [[BranchLogger shared] logDebug:[NSString stringWithFormat:@"Handling Event: %@", event] error:nil];
    [[BranchLogger shared] logDebug:[NSString stringWithFormat:@"Handling Event Type: %@", event.source] error:nil];
    [[BranchLogger shared] logDebug:[NSString stringWithFormat:@"Handling Event Source: %@", event.type] error:nil];
    [[BranchLogger shared] logDebug:[NSString stringWithFormat:@"Adobe Branch Extension Event Types: %@", [AdobeBranchExtensionConfig instance].eventTypes] error:nil];
    [[BranchLogger shared] logDebug:[NSString stringWithFormat:@"Adobe Branch Extension Event Sources: %@", [AdobeBranchExtensionConfig instance].eventSources] error:nil];
    
    if ([[AdobeBranchExtensionConfig instance].eventTypes containsObject:event.type] &&
        [[AdobeBranchExtensionConfig instance].eventSources containsObject:event.source]) {
        [self trackEvent:event];
    } else if ([event.type isEqualToString:ABEAdobeHubEventType] &&
               [event.source isEqualToString:ABEAdobeSharedStateEventSource] &&
               ([event.data[ABEAdobeEventDataKey_StateOwner] isEqualToString:ABEAdobeIdentityExtension] ||
                [event.data[ABEAdobeEventDataKey_StateOwner] isEqualToString:ABEAdobeAnalyticsExtension])) {
        [self passAdobeIdsToBranch:event];
    }
}

NSString *_Nonnull BNCStringWithObject(id<NSObject> object) {
    if (object == nil) return @"";
    if ([object isKindOfClass:NSString.class]) {
        return (NSString*) object;
    } else
        if ([object respondsToSelector:@selector(stringValue)]) {
            return [(id)object stringValue];
        } else
            if ([object respondsToSelector:@selector(description)]) {
                return [object description];
            }
    return [NSString stringWithFormat:@"Object of type %@", NSStringFromClass(object.class)];
}

NSMutableDictionary *BNCStringDictionaryWithDictionary(NSDictionary*dictionary_) {
    if (![dictionary_ isKindOfClass:NSDictionary.class]) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for (id<NSObject> key in dictionary_.keyEnumerator) {
        NSString *stringValue = BNCStringWithObject(dictionary_[key]);
        NSString *stringKey = BNCStringWithObject(key);
        if (stringKey.length && stringValue != nil) dictionary[stringKey] = stringValue;
    }
    return dictionary;
}

+ (BranchEvent *)branchEventFromAdobeEventName:(NSString *)eventName
                                    dictionary:(NSDictionary *)dictionary {
    
    if (eventName.length == 0) return nil;
    BranchEvent *event = [[BranchEvent alloc] initWithName:eventName];
    if (!dictionary) return event;
    
    /* Translate some special fields to BranchEvent, otherwise add the dictionary as BranchEvent.userData:
     
     currency
     revenue
     shipping
     tax
     coupon
     affiliation
     eventDescription
     searchQuery
     transactionID
    
     */
    
    #define stringForKey(key) \
    BNCStringWithObject(dictionary[@#key])
    
    NSString *value = stringForKey(currency);
    if (value.length) event.currency = value;
    
    value = stringForKey(revenue);
    if (value.length) event.revenue = [NSDecimalNumber decimalNumberWithString:value];
    
    value = stringForKey(shipping);
    if (value.length) event.shipping = [NSDecimalNumber decimalNumberWithString:value];
    
    value = stringForKey(tax);
    if (value.length) event.tax = [NSDecimalNumber decimalNumberWithString:value];
    
    value = stringForKey(coupon);
    if (value.length) event.coupon = value;
    
    value = stringForKey(affiliation);
    if (value.length) event.affiliation = value;
    
    value = stringForKey(transaction_id);
    if (value.length) event.transactionID = value;
    
    value = stringForKey(title);
    if (value.length == 0) value = stringForKey(name);
    if (value.length == 0) value = stringForKey(description);
    if (value.length) event.eventDescription = value;
    
    value = stringForKey(query);
    if (value.length) event.searchQuery = value;
    
    #undef stringForKey
    
    event.customData = BNCStringDictionaryWithDictionary(dictionary);
    return event;
}

- (void) trackEvent:(AEPEvent*)event {
    [[BranchLogger shared] logVerbose: @"trackEvent" error:nil];

    NSString *eventName = getEventNameFromEvent(event);
    
    if (!eventName.length) return;
    if (![self isValidEventForBranch:eventName]) return;
    NSDictionary *content = getContentFromEvent(event);
    BranchEvent *branchEvent = [self.class branchEventFromAdobeEventName:eventName dictionary:content];
    [branchEvent logEvent];
    
    [self deviceDataSharedState:event];
}

NSDictionary* getContentFromEvent(AEPEvent *event) {
    NSString *hitUrl = event.data[@"hitUrl"];
    if (!hitUrl) {
        return nil;
    }
    
    NSArray *parameters = [hitUrl componentsSeparatedByString:@"&"];
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    
    for (NSString *param in parameters) {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        if (keyValue.count == 2) {
            NSString *key = keyValue[0];
            NSString *value = keyValue[1];
            value = [value stringByRemovingPercentEncoding];
            [content setObject:value forKey:key];
        }
    }
    
    return [content copy];
}

NSString* getEventNameFromEvent(AEPEvent *event) {
    NSString *hitUrl = event.data[@"hitUrl"];
    if (!hitUrl) {
        return nil;
    }
    
    NSArray *parameters = [hitUrl componentsSeparatedByString:@"&"];
    NSString *action = nil;
    
    for (NSString *param in parameters) {
        if ([param containsString:@"action="]) {
            action = [[param componentsSeparatedByString:@"="] lastObject];
            action = [action stringByRemovingPercentEncoding];
            break;
        }
    }
    
    return action;
}


- (BOOL)isValidEventForBranch:(NSString*)eventName {
    [[BranchLogger shared] logVerbose: @"isValidEventForBranch" error:nil];

    if ([AdobeBranchExtensionConfig instance].exclusionList.count == 0 && [AdobeBranchExtensionConfig instance].allowList.count == 0) {
        return YES;
    } else if ([AdobeBranchExtensionConfig instance].allowList.count != 0 && [[AdobeBranchExtensionConfig instance].allowList containsObject: eventName]) {
        return YES;
    } else if ([AdobeBranchExtensionConfig instance].exclusionList.count != 0 && ![[AdobeBranchExtensionConfig instance].exclusionList containsObject: eventName]) {
        return YES;
    }
    return NO;
}

- (void) passAdobeIdsToBranch:(AEPEvent*)eventToProcess {
    AEPSharedStateResult *configSharedState = [self.runtime getSharedStateWithExtensionName:eventToProcess.data[ABEAdobeEventDataKey_StateOwner] event:eventToProcess barrier:NO];
    [[BranchLogger shared] logVerbose:[NSString stringWithFormat:@"Configuration shared state value: %@", configSharedState.value]  error:nil];
    
    Branch *branch = [Branch getInstance];
    
    [AEPMobileEdgeIdentity getExperienceCloudId:^(NSString * _Nullable ecid, NSError * _Nullable error) {
        
        // Check for an error
        if (error) {
            [[BranchLogger shared] logError:@"Error getting ECID." error:error];
            return;
        }
        
        // Check if the ECID is nil or empty
        if (!ecid || [ecid length] == 0) {
            [[BranchLogger shared] logVerbose:@"ECID was nil or empty." error:nil];
            return;
        }

        [[BranchLogger shared] logVerbose:[NSString stringWithFormat:@"ECID retrieved: %@", ecid]  error:nil];
        [branch setRequestMetadataKey:@"$marketing_cloud_visitor_id" value:ecid];
    }];
}

- (void) deviceDataSharedState: (nullable AEPEvent*) event {
    NSDictionary* newDeviceData =  [[BranchPluginSupport instance] deviceDescription];
    [self.runtime createSharedStateWithData:newDeviceData event:event];
}

@end
