//
//  BranchExtension.m
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Branch. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import <Branch/Branch.h>

#pragma mark Constants

NSString*const ABEBranchExtensionVersion        = @"0.1.6";

NSString*const ABEBranchEventType               = @"com.branch.eventType";
NSString*const ABEBranchEventSource             = @"com.branch.eventSource";

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
    [[self bnc_branchInstance] initSessionWithLaunchOptions:options andRegisterDeepLinkHandler:callback];
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    return [[self bnc_branchInstance] continueUserActivity:userActivity];
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [[self bnc_branchInstance] application:application openURL:url options:options];
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    BNCLogSetDisplayLevel(BNCLogLevelAll); // TODO: Show all logging for now. Turn off later.

    NSError *error = nil;
    if ([self.api registerWildcardListener:AdobeBranchExtensionListener.class error:&error])
        BNCLogDebug(@"BranchExtensionRuleListener was registered.");
    else
        BNCLogError(@"Can't register AdobeBranchExtensionRuleListener: %@.", error);
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

    if ([event.eventType isEqualToString:@"com.adobe.eventType.generic.track"] &&
        [event.eventSource isEqualToString:@"com.adobe.eventSource.requestContent"]) {
        [self trackEvent:event];
        return;
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

+ (BranchEvent *)branchEventFromAdbobeEventName:(NSString *)eventName
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
    BranchEvent *branchEvent = [self.class branchEventFromAdbobeEventName:eventName dictionary:content];
    [branchEvent logEvent];
}

@end
