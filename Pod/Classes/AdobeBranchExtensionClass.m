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

NSString*const ABEBranchEventNameInitialize     = @"branch-init";
NSString*const ABEBranchEventNameShowShareSheet = @"branch-share-sheet";
NSString*const ABEBranchEventNameDeepLinkOpened = @"branch-deep-link-opened";

NSString*const ABEBranchEventType               = @"com.branch.eventType";
NSString*const ABEBranchEventSource             = @"com.branch.eventSource";

NSString*const ABEBranchLinkTitleKey            = @"contentTitle";
NSString*const ABEBranchLinkSummaryKey          = @"contentDescription";
NSString*const ABEBranchLinkImageURLKey         = @"contentImage";
NSString*const ABEBranchLinkCanonicalURLKey     = @"canonicalURLKey";
NSString*const ABEBranchLinkUserInfoKey         = @"userInfo";
NSString*const ABEBranchLinkCampaignKey         = @"campaign";
NSString*const ABEBranchLinkTagsKey             = @"tags";
NSString*const ABEBranchLinkShareTextKey        = @"shareText";
NSString*const ABEBranchLinkIsFirstSessionKey   = @"isFirstSession";

NSString*const ABEBranchConfigBranchKey         = @"branchKey";

NSString*const ABEBranchDeepLinkNotification    = @"ABEBranchDeepLinkNotification";

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

#pragma mark -

@interface AdobeBranchExtension()
@property (strong) NSDictionary<NSString*,NSValue*>*eventTable;
@end

@implementation AdobeBranchExtension

+ (void) initialize {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(applicationLaunchNotification:)
        name:UIApplicationDidFinishLaunchingNotification
        object:nil];
}

static NSDictionary*bnc_launchOptions = nil;

+ (void) applicationLaunchNotification:(NSNotification*)notification {
    bnc_launchOptions = notification.userInfo;
}

static Branch*bnc_branchInstance = nil;

+ (Branch*) branch {
    return bnc_branchInstance;
}

+ (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    return [bnc_branchInstance continueUserActivity:userActivity];
}

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    return [bnc_branchInstance application:application openURL:url options:options];
}

- (instancetype) init {
    self = [super init];
    if (!self) return self;

    BNCLogSetDisplayLevel(BNCLogLevelAll); // Show all logging for now.

    self.eventTable = @{
        ABEBranchEventNameInitialize:     [NSValue valueWithPointer:@selector(branchInit:)],
        @"deep-link-route":               [NSValue valueWithPointer:@selector(deepLinkRoute:)],
//      @"branch-deep-link-received":     [NSValue valueWithPointer:@selector(branchDeepLinkReceived:)],
        ABEBranchEventNameShowShareSheet: [NSValue valueWithPointer:@selector(branchShareSheet:)],
    };

    NSError* error = nil;
    if ([self.api registerWildcardListener:AdobeBranchExtensionListener.class error:&error]) {
        BNCLogDebug(@"BranchExtensionRuleListener was registered.");
    } else {
        BNCLogError(@"Can't register AdobeBranchExtensionRuleListener: %@.", error);
    }

    ACPExtensionEvent* initEvent =
        [ACPExtensionEvent extensionEventWithName:ABEBranchEventNameInitialize
            type:ABEBranchEventType
            source:ABEBranchEventSource
            data:@{}
            error:&error];
    if (![self.api setSharedEventState:@{} event:initEvent error:&error]) {
        BNCLogError(@"Can't set shared state: %@.", error);
    }
    if (![ACPCore dispatchEvent:initEvent error:&error]) {
        BNCLogError(@"Can't dispatch event %@.", error);
    }

    return self;
}

- (nullable NSString*) name {
    return @"com.branch.extension";
}

- (nullable NSString*) version {
    return @"1.0.0"; // TODO: Read version number from package config instead
}

- (void) handleEvent:(ACPExtensionEvent*)event {
    BNCLogDebug(@"Event: %@", event);
    if ([event.eventType isEqualToString:@"com.adobe.eventType.generic.track"] &&
        [event.eventSource isEqualToString:@"com.adobe.eventSource.requestContent"]) {
        [self trackEvent:event];
        return;
    }
    SEL selector = [self.eventTable[event.eventName] pointerValue];
    if (selector) {
        [self performSelectorOnMainThread:selector withObject:event waitUntilDone:NO];
    }
}

#pragma mark - Deep Linking

- (void) branchInit:(ACPExtensionEvent*)event {
    NSDictionary* configuration =
        [self.api getSharedEventState:@"com.adobe.module.configuration" event:event error:nil];
    NSString*branchKey = configuration[ABEBranchConfigBranchKey];
    if (branchKey.length <= 0) return;

    __weak __typeof(self) weak_self = self;
    NSDictionary *launchOptions = bnc_launchOptions ?: @{};
    bnc_branchInstance = [Branch getInstance:branchKey];
    [self.class.branch initSessionWithLaunchOptions:launchOptions
        isReferrable:YES
        andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            __strong __typeof(weak_self) strong_self = weak_self;
            [strong_self handleDeepLinkParams:params error:error];
        }];
}

- (void) handleDeepLinkParams:(NSDictionary*)params error:(NSError*)error_ {
    if (![[params objectForKey:@"+clicked_branch_link"] boolValue])
        return;
    BNCLogDebug(@"Received deep link: %@.", params);

    // Clean up the params first, preventing integer overflow, for example.
    NSMutableDictionary*mutableParams   = [params mutableCopy];
    mutableParams[@"$identity_id"]      = [mutableParams[@"$identity_id"] description];
    mutableParams[@"~id"]               = [mutableParams[@"~id"] description];

    NSMutableDictionary*data = NSMutableDictionary.new;
    data[ABEBranchLinkTitleKey]          = params[@"$og_title"];
    data[ABEBranchLinkSummaryKey]        = params[@"$og_description"];
    data[ABEBranchLinkImageURLKey]       = params[@"$og_image_url"];
    data[ABEBranchLinkCanonicalURLKey]   = params[@"$canonical_url"];
    data[ABEBranchLinkUserInfoKey]       = mutableParams;
    data[ABEBranchLinkCampaignKey]       = params[@"~campaign"];
    data[ABEBranchLinkTagsKey]           = params[@"~tags"];
    data[ABEBranchLinkIsFirstSessionKey] = params[@"+is_first_session"];

    NSError*error = nil;
    ACPExtensionEvent*event =
        [ACPExtensionEvent extensionEventWithName:ABEBranchEventNameDeepLinkOpened
            type:ABEBranchEventType
            source:ABEBranchEventSource
            data:data
            error:&error];
    // TODO: See if we can add Branch deep link data to sharedShared state
    if ([ACPCore dispatchEvent:event error:&error]) {
       BNCLogError(@"Can't dispatch event: %@.", error);
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:ABEBranchDeepLinkNotification
        object:self
        userInfo:data];
}

- (void) deepLinkRoute:(NSDictionary*)detail {
    // TODO: Implement deep linking here
    NSLog(@"Deep link routed: %@.", detail);
/*
//  NSString *deepLinkController = [consequenceDetail objectForKey:@"deepLinkController"];

    UINavigationController *navigationController =
        (id) [UIApplication sharedApplication].delegate.window.rootViewController;


    //            NSString *productName = [params objectForKey:@"productName"];
    NSString *productName = @"glasses";
    NSDictionary *params = @{@"productName":@"glasses"};
    //            //UIViewController *nextVC;
    ProductViewController *nextVC;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (productName) {
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
        nextVC.product = Product.new;
        nextVC.product.name =
        [navigationController pushViewController:nextVC animated:YES];
        //[navC setViewControllers:@[nextVC] animated:YES];
        //[navC pushViewController:nextVC animated:NO];
    }
*/
}

#pragma mark - Creating & Sharing Links

- (void) branchShareSheet:(ACPExtensionEvent*)event {
    /*
    *Branch Link Fields*

    FOUNDATION_EXPORT NSString* const ABEBranchLinkTitleKey;
    FOUNDATION_EXPORT NSString* const ABEBranchLinkSummaryKey;
    FOUNDATION_EXPORT NSString* const ABEBranchLinkImageURLKey;
    FOUNDATION_EXPORT NSString* const ABEBranchLinkCanonicalURLKey;
    FOUNDATION_EXPORT NSSTring* const ABEBranchLinkUserInfoKey;
    FOUNDATION_EXPORT NSSTring* const ABEBranchLinkCampaignKey;
    FOUNDATION_EXPORT NSSTring* const ABEBranchLinkShareTextKey;
    FOUNDATION_EXPORT NSSTring* const ABEBranchLinkTagsKey;
    */

    NSDictionary*data = event.eventData;
    BranchUniversalObject *buo = BranchUniversalObject.new;
    buo.title = data[ABEBranchLinkTitleKey];
    buo.contentDescription = data[ABEBranchLinkSummaryKey];
    buo.imageUrl = data[ABEBranchLinkImageURLKey];
    buo.canonicalUrl = data[ABEBranchLinkCanonicalURLKey];
    buo.contentMetadata.customMetadata = data[ABEBranchLinkUserInfoKey];
    if (buo.title.length == 0 && buo.canonicalUrl.length == 0) {
        BNCLogError(@"Canonical ID or title must be set for Branch Universal Objects");
        return;
    }
    buo.locallyIndex = YES;

    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.campaign = data[ABEBranchLinkCampaignKey];
    NSArray*tags = data[ABEBranchLinkTagsKey];
    if ([tags isKindOfClass:NSString.class]) {
        tags = @[ tags ];
    }
    if ([tags isKindOfClass:NSArray.class]) {
        lp.tags = tags;
    }

    BranchShareLink*shareLink =
        [[BranchShareLink alloc] initWithUniversalObject:buo linkProperties:lp];
    shareLink.title = buo.title ?: @"";
    shareLink.shareText = data[ABEBranchLinkShareTextKey] ?: @"";
    [shareLink presentActivityViewControllerFromViewController:nil anchor:nil];
}

#pragma mark - Action Events

+ (NSString*) stringFromObject:(id<NSObject>)object {
    if (object == nil) return nil;
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

+ (NSMutableDictionary*) stringDictionaryFromDictionary:(NSDictionary*)dictionary_ {
    if (dictionary_ == nil) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for(id<NSObject> key in dictionary_.keyEnumerator) {
        NSString* stringValue = [self stringFromObject:dictionary_[key]];
        NSString* stringKey = [self stringFromObject:key];
        if (stringKey.length) dictionary[stringKey] = stringValue;
    }
    return dictionary;
}

+ (BranchEvent*) branchEventFromAdbobeEventName:(NSString*)eventName
                                 dictionary:(NSDictionary*)dictionary {

    if (eventName.length == 0) return nil;
    BranchEvent *event = [[BranchEvent alloc] initWithName:eventName];
    if (!dictionary) return event;

    /* Translate some special fields, otherwise add the dictionary as BranchEvent.userData:

    currency
    revenue
    shipping
    tax
    coupon
    affiliation
    eventDescription
    searchQuery
    */

    NSString*value = dictionary[@"currency"];
    if (value.length) event.currency = value;

    value = dictionary[@"revenue"];
    if (value.length) event.revenue = [NSDecimalNumber decimalNumberWithString:value];

    value = dictionary[@"shipping"];
    if (value.length) event.shipping = [NSDecimalNumber decimalNumberWithString:value];

    value = dictionary[@"tax"];
    if (value.length) event.tax = [NSDecimalNumber decimalNumberWithString:value];

    value = dictionary[@"coupon"];
    if (value.length) event.coupon = value;

    value = dictionary[@"affiliation"];
    if (value.length) event.affiliation = value;

    value = dictionary[@"title"];
    if (value.length == 0) value = dictionary[@"name"];
    if (value.length == 0) value = dictionary[@"description"];
    if (value.length) event.eventDescription = value;

    value = dictionary[@"query"];
    if (value.length) event.searchQuery = value;

    event.customData = [self.class stringDictionaryFromDictionary:dictionary];
    return event;
}

- (void) trackEvent:(ACPExtensionEvent*)event {
    NSDictionary*eventData = event.eventData;
    NSString*eventName = [eventData objectForKey:@"action"];
    if (!eventName.length) return;
    NSDictionary*content = [eventData objectForKey:@"contextdata"];
    BranchEvent*branchEvent = [self.class branchEventFromAdbobeEventName:eventName dictionary:content];
    [branchEvent logEvent];
}

@end
