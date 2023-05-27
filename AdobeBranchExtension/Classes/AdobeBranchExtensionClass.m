//
//  BranchExtension.m
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import "AdobeBranchExtensionConfig.h"
#import <BranchSDK/Branch.h>
#import <BranchSDK/BNCLog.h>
#import <BranchSDK/BranchPluginSupport.h>
#import <BranchSDK/BranchEvent.h>

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
NSString *const ABEAdobeIdentityExtension = @"com.adobe.module.identity";
NSString *const ABEAdobeAnalyticsExtension = @"com.adobe.module.analytics";
// 4. will contain Adobe ID values needed to be passed to Branch prior to session initialization

#pragma mark -

@interface AdobeBranchExtension()
@end

@implementation AdobeBranchExtension {
    id<AEPExtensionRuntime> runtime_;
    NSString * stateValue;
}


- (NSString *)name {
    return @"io.branch.adobe.extension";
}

- (NSString *)friendlyName {
    return @"AdobeBranchExtension";
}

+ (NSString * _Nonnull)extensionVersion {
    return ADOBE_BRANCH_VERSION;
}

//TODO: Update this
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

    [runtime_ registerListenerWithType:@"" source:@"" listener:^(AEPEvent * _Nonnull event) {
        [self handleEvent: event];
        //This is where we need to handle events that come in
    }];
}

- (void)onUnregistered {}

- (BOOL)readyForEvent:(AEPEvent * _Nonnull)event {
    AEPSharedStateResult *result = [runtime_ getSharedStateWithExtensionName:self.name event:event barrier:NO];
    if (!result) {
        return false;
    }
    
    BNCLogDebug([NSString stringWithFormat:@"Ready for event: %@", event.name]);

    return result.status == AEPSharedStateStatusSet;
}

//This is where filtering occured previously
- (void)handleEvent:(AEPEvent*)event {
    BNCLogDebug([NSString stringWithFormat:@"Event: %@", event]);

    if ([[AdobeBranchExtensionConfig instance].eventTypes containsObject:event.type] &&
        [[AdobeBranchExtensionConfig instance].eventSources containsObject:event.source]) {
        BNCLogDebug(@"BranchSDK_ Could not process event, configuration shared state is pending");
        [self trackEvent:event];
    } else if ([event.type isEqualToString:ABEAdobeHubEventType] &&
               [event.source isEqualToString:ABEAdobeSharedStateEventSource] &&
               ([event.data[ABEAdobeEventDataKey_StateOwner] isEqualToString:ABEAdobeIdentityExtension] ||
                [event.data[ABEAdobeEventDataKey_StateOwner] isEqualToString:ABEAdobeAnalyticsExtension])) {
        [self passAdobeIdsToBranch:event];
    }
}


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
            BNCLogError([NSString stringWithFormat:@"AdobeBranchExtensionConfig error: %@.", *configError]);
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
            BNCLogError([NSString stringWithFormat:@"AdobeBranchExtensionConfig error: %@.", *configError]);
            return NO;
        } else {
            [AdobeBranchExtensionConfig instance].allowList = eventNames;
        }
    }
    return YES;
}

/*
 /// Registers an `EventListener` for the specified `EventType` and `EventSource`
 /// - Parameters:
 ///   - type: `EventType` to listen for
 ///   - source: `EventSource` to listen for
 ///   - listener: Function or closure which will be invoked whenever the `EventHub` receives an `Event` matching `type` and `source`
 func registerListener(type: String, source: String, listener: @escaping EventListener)
 */

//- (instancetype)init {
//    self = [super init];
//    if (!self) return self;
//
//    BNCLogSetDisplayLevel(BNCLogLevelError);
//
//    NSError *error = nil;
////    if ([self.runtime registerListenerWithType:<#(NSString * _Nonnull)#> source:<#(NSString * _Nonnull)#> listener:<#^(AEPEvent * _Nonnull)listener#>]) {
////        BNCLogDebug(@"BranchExtensionRuleListener was registered.");
////    } else {
////        BNCLogError([NSString stringWithFormat:@"Can't register AdobeBranchExtensionRuleListener: %@.", error]);
////    }
//    return self;
//}



#pragma mark - Action Events

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
        if (stringKey.length && stringValue.length) dictionary[stringKey] = stringValue;
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
    NSDictionary *eventData = event.data;
    NSString *eventName = eventData[@"action"];
    if (!eventName.length) eventName = eventData[@"state"];
    if (!eventName.length) return;
    if (![self isValidEventForBranch:eventName]) return;
    NSDictionary *content = [eventData objectForKey:@"contextdata"];
    BranchEvent *branchEvent = [self.class branchEventFromAdobeEventName:eventName dictionary:content];
    [branchEvent logEvent];
    BNCLogDebug(@"BranchSDK_ Logged Branch Event");

    [self deviceDataSharedState:event];
}

- (BOOL)isValidEventForBranch:(NSString*)eventName {
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
    NSError *error = nil;
    AEPSharedStateResult *configSharedState = [self.runtime getSharedStateWithExtensionName:self.name event:eventToProcess barrier:NO];

    if (!configSharedState.value) {
        BNCLogDebug(@"BranchSDK_ Could not process event, configuration shared state is pending");
        return;
    }
    if (error) {
        BNCLogDebug(@"BranchSDK_ Could not process event, an error occured while retrieving configuration shared state");
        return;
    }
    Branch *branch = [Branch getInstance];
    
    for (id key in configSharedState.value.allKeys) {
        NSLog(@"BranchSDK_ key=%@ value=%@", key, [configSharedState.value objectForKey:key]);
        NSString *idAsString = [NSString stringWithFormat:@"%@", [configSharedState.value objectForKey:key]];

        if (!idAsString || [idAsString isEqualToString:@""]) continue;

        if ([key isEqualToString:@"mid"]) {
            [branch setRequestMetadataKey:@"$marketing_cloud_visitor_id" value:idAsString];
        } else if ([key isEqualToString:@"vid"]) {
            [branch setRequestMetadataKey:@"$analytics_visitor_id" value:idAsString];
        } else if ([key isEqualToString:@"aid"]) {
            [branch setRequestMetadataKey:@"$adobe_visitor_id" value:idAsString];
       }
    }
}

- (void) deviceDataSharedState: (nonnull AEPEvent*) event {

    NSDictionary* newDeviceData =  [[BranchPluginSupport instance] deviceDescription];
    [self.runtime createSharedStateWithData:newDeviceData event:event];
}

@end
