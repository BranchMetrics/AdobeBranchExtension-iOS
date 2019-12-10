//
//  BranchExtension.m
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "ACPCore.h"
#import "AdobeBranchExtension.h"
#import "AdobeBranchExtensionConfig.h"
#import <Branch/Branch.h>

#pragma mark Constants

//// if owner type (i.e. extension/module) hat causes shared state events
//NSString *const SHARED_STATE_CONFIGURATION = @"com.adobe.module.configuration";

NSString*const ABEBranchExtensionVersion        = @"1.2.0";

NSString*const ABEBranchEventType               = @"com.branch.eventType";
NSString*const ABEBranchEventSource             = @"com.branch.eventSource";

// events of this type and source
NSString *const EVENT_TYPE_ADOBE_HUB = @"com.adobe.eventtype.hub";
NSString *const ADOBE_SHARED_STATE_EVENT_SOURCE = @"com.adobe.eventsource.sharedstate";
// whose owner (extension/module causing the specific event)
NSString *const SHARED_STATE_OWNER = @"stateowner";
// is either
NSString *const ADOBE_IDENTITY_EXTENSION = @"com.adobe.module.identity";
NSString *const ADOBE_ANALYTICS_EXTENSION = @"com.adobe.module.analytics";
// will contain Adobe ID values needed to be passed to Branch prior to session initialization

#pragma mark -

@interface ACPExtensionEvent (AdobeBranchExtension)
- (NSString*) description;
@end

@implementation ACPExtensionEvent (AdobeBranchExtension)

- (NSString*) description {
    return [NSString stringWithFormat:@"<%@ %p name:'%@' type:'%@' source'%@'\n%@>",
        NSStringFromClass(self.class),
        (void*)self,
        self.eventName,
        self.eventType,
        self.eventSource,
        self.eventData
    ];
}

@end

@interface AdobeBranchExtension()
@property (nonatomic, strong, readwrite) NSString *experienceCloudID;
@property (nonatomic, strong, readwrite) NSString *analyticsCustomVisitorID;
@property (nonatomic, strong, readwrite) NSString *analyticsVisitorID;
@end

@implementation AdobeBranchExtension

+ (Branch *)bnc_branchInstance {
    static Branch *branchInstance = nil;

    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if (!branchInstance) {
            branchInstance = [Branch getInstance];
        }
    });

    return branchInstance;
}

+ (void)initSessionWithLaunchOptions:(NSDictionary *)options andRegisterDeepLinkHandler:(callbackWithParams)callback {
    [self delayInitSessionToCollectAdobeIDs];
    [[self bnc_branchInstance] initSessionWithLaunchOptions:options andRegisterDeepLinkHandler:callback];
}

+ (void) delayInitSessionToCollectAdobeIDs {
    [self.bnc_branchInstance dispatchToIsolationQueue:^{
        // we use semaphore to block Branch session initialization thread, we wait for 2 seconds
        // to populate experienceCloudID/analyticsCustomVisitorID/analyticsVisitorID properties,
        // then pass them to Branch as request metadata and release the semaphore
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            id experienceCloudID_ = [self valueForKey:@"experienceCloudID"];
            id analyticsCustomVisitorID_ = [self valueForKey:@"analyticsCustomVisitorID"];
            id analyticsVisitorID_ = [self valueForKey:@"analyticsVisitorID"];
            if (experienceCloudID_ && ![experienceCloudID_ isEqualToString:@""]) {
                [self.bnc_branchInstance setRequestMetadataKey:@"$marketing_cloud_visitor_id" value:experienceCloudID_];
            }
            if (analyticsCustomVisitorID_ && ![analyticsCustomVisitorID_ isEqualToString:@""]) {
                [self.bnc_branchInstance setRequestMetadataKey:@"$analytics_visitor_id" value:analyticsCustomVisitorID_];
            }
            if (analyticsVisitorID_ && ![analyticsVisitorID_ isEqualToString:@""]) {
                [self.bnc_branchInstance setRequestMetadataKey:@"$adobe_visitor_id" value:analyticsVisitorID_];
            }
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    return [[self bnc_branchInstance] continueUserActivity:userActivity];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [[self bnc_branchInstance] application:application openURL:url options:options];
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

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    BNCLogSetDisplayLevel(BNCLogLevelError);

    NSError *error = nil;
    if ([self.api registerWildcardListener:AdobeBranchExtensionListener.class error:&error]) {
        BNCLogDebug(@"BranchExtensionRuleListener was registered.");
    } else {
        BNCLogError(@"Can't register AdobeBranchExtensionRuleListener: %@.", error);
    }
    return self;
}

- (nullable NSString *)name {
    return @"io.branch.adobe.extension";
}

- (nullable NSString *)version {
    return ABEBranchExtensionVersion;
}

- (void)handleEvent:(ACPExtensionEvent*)event {
    BNCLogDebug(@"Event: %@", event);

    if ([[AdobeBranchExtensionConfig instance].eventTypes containsObject:event.eventType] &&
        [[AdobeBranchExtensionConfig instance].eventSources containsObject:event.eventSource]) {
        [self trackEvent:event];
    } else if ([event.eventType isEqualToString:EVENT_TYPE_ADOBE_HUB] &&
               [event.eventSource isEqualToString:ADOBE_SHARED_STATE_EVENT_SOURCE] &&
               ([event.eventData[SHARED_STATE_OWNER] isEqualToString:ADOBE_IDENTITY_EXTENSION] ||
                [event.eventData[SHARED_STATE_OWNER] isEqualToString:ADOBE_ANALYTICS_EXTENSION])) {
        [self respondtoIDEvent:event];
    }
}

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

    /* Translate some special fields tp BranchEvent, otherwise add the dictionary as BranchEvent.userData:

    currency
    revenue
    shipping
    tax
    coupon
    affiliation
    eventDescription
    searchQuery
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

- (void) trackEvent:(ACPExtensionEvent*)event {
    NSDictionary *eventData = event.eventData;
    NSString *eventName = eventData[@"action"];
    if (!eventName.length) eventName = eventData[@"state"];
    if (!eventName.length) return;
    NSDictionary *content = [eventData objectForKey:@"contextdata"];
    BranchEvent *branchEvent = [self.class branchEventFromAdobeEventName:eventName dictionary:content];
    [branchEvent logEvent];
}

- (void) respondtoIDEvent:(ACPExtensionEvent*)eventToProcess {
    NSError *error = nil;
    NSDictionary *configSharedState = [self.api getSharedEventState:eventToProcess.eventData[SHARED_STATE_OWNER]
                                                              event:eventToProcess error:&error];
    if (!configSharedState) {
        BNCLogDebug(@"Could not process event, configuration shared state is pending");
        return;
    }
    if (!error) {
        BNCLogDebug(@"Could not process event, an error occured while retrieving configuration shared state");
        return;
    }
    for(id key in configSharedState) {
        NSLog(@"key=%@ value=%@", key, [configSharedState objectForKey:key]);
        if ([key isEqualToString:@"mid"]) {
//            [self setExperienceCloudID:(NSString *) [configSharedState objectForKey:key]];
            self.experienceCloudID = (NSString *) [configSharedState objectForKey:key];
        } else if ([key isEqualToString:@"vid"]) {
            self.analyticsCustomVisitorID =(NSString *) [configSharedState objectForKey:key];
        } else if ([key isEqualToString:@"aid"]) {
           self.analyticsVisitorID = (NSString *) [configSharedState objectForKey:key];
       }
    }
}

@end
