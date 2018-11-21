//
//  BranchExtensionRuleListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import <Branch/Branch.h>
#import <Branch/BNCThreads.h>

@interface ACPExtensionEvent (Branch)
- (NSString*) description;
@end

@implementation ACPExtensionEvent (Branch)

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

#pragma mark - BranchExtensionRuleListener

@implementation BranchExtensionRuleListener

//po event.eventData
//{
//    triggeredconsequence =     {
//        detail =         {
//            campaign = tete;
//            channel = ete;
//            tags = tetete;
//        };
//        id = RCc140c5095d244b92b89f379a3c1b6e71;
//        type = "show-share-sheet";
//    };
//}

- (void) showConsequenceDeepLinkRoute:(NSDictionary*)detail {
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

- (void) hear:(ACPExtensionEvent*)event {
    BNCLog(@"Event: %@", event);
    NSString *eventType = [event eventType];
    if (![eventType isEqualToString:@"com.adobe.eventType.rulesEngine"])
        return;

//  NSString *eventSource = [event eventSource];

    NSDictionary*consequence = event.eventData[@"triggeredconsequence"];
    NSString*type = consequence[@"type"];
    NSDictionary*detail = consequence[@"detail"];

    // TODO: Add more secure check for Branch events in case someone tries to spoof Branch rules ??

    if ([type isEqualToString:@"deep-link-route"]) {
        BNCPerformBlockOnMainThreadAsync(^{
            [self showConsequenceDeepLinkRoute:detail];
        });
    } else
    if ([type isEqualToString:@"show-share-sheet"]) {
        BNCPerformBlockOnMainThreadAsync(^ {
            [self showShareSheet:detail];
        });
    }
    if ([event.eventType isEqualToString:@"com.adobe.eventType.generic.track"] &&
        [event.eventSource isEqualToString:@"com.adobe.eventSource.requestContent"]) {
        [self trackEvent:event.eventData];
    }
}

- (void) showShareSheet:(NSDictionary*)data {
    /*
    *Adobe Fields*

    campaign = share;
    contentDescription = MyContent;
    contentImage = "https://cdn.branch.io/branch-assets/1538165719615-og_image.jpeg";
    contentTitle = BranchGlasses;
    shareText = MyDemoShareText;
    tags = tag;
    */

    BranchUniversalObject *buo = BranchUniversalObject.new;
    buo.title = data[@"contentTitle"];
    buo.canonicalIdentifier = data[@"canonicalIdentifier"];
    if (buo.title.length == 0 && buo.canonicalIdentifier.length == 0) {
        BNCLogError(@"Canonical ID or title must be set for Branch Universal Objects");
        return;
    }
    buo.contentDescription = data[@"contentDescription"];
    buo.imageUrl = data[@"contentImage"];
    buo.locallyIndex = YES;

    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.campaign = data[@"campaign"];
    NSArray*tags = data[@"tags"];
    if ([tags isKindOfClass:NSString.class]) {
        tags = @[ tags ];
    }
    if ([tags isKindOfClass:NSArray.class]) {
        lp.tags = tags;
    }

    BranchShareLink*shareLink =
        [[BranchShareLink alloc] initWithUniversalObject:buo linkProperties:lp];
    shareLink.title = buo.title ?: @"";
    shareLink.shareText = data[@"shareText"] ?: @"";
    [shareLink presentActivityViewControllerFromViewController:nil anchor:nil];
}

#pragma mark - Events

+ (BNCProductCategory) categoryFromString:(NSString*)string {
    if (string.length == 0) return nil;

    NSArray *categories = @[
        BNCProductCategoryAnimalSupplies,
        BNCProductCategoryApparel,
        BNCProductCategoryArtsEntertainment,
        BNCProductCategoryBabyToddler,
        BNCProductCategoryBusinessIndustrial,
        BNCProductCategoryCamerasOptics,
        BNCProductCategoryElectronics,
        BNCProductCategoryFoodBeverageTobacco,
        BNCProductCategoryFurniture,
        BNCProductCategoryHardware,
        BNCProductCategoryHealthBeauty,
        BNCProductCategoryHomeGarden,
        BNCProductCategoryLuggageBags,
        BNCProductCategoryMature,
        BNCProductCategoryMedia,
        BNCProductCategoryOfficeSupplies,
        BNCProductCategoryReligious,
        BNCProductCategorySoftware,
        BNCProductCategorySportingGoods,
        BNCProductCategoryToysGames,
        BNCProductCategoryVehiclesParts,
    ];

    for (BNCProductCategory category in categories) {
        if ([string compare:category options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch] == NSOrderedSame)
            return category;
    }
    return nil;
}

#define addStringField(field, name) { \
    NSString *value = dictionary[@#name]; \
    if (value) { \
        if ([value isKindOfClass:NSString.class]) \
            field = value; \
        else \
            field = [value description]; \
        dictionary[@#name] = nil; \
    } \
}

#define addDecimalField(field, name) { \
    NSString *value = dictionary[@#name]; \
    if (value) { \
        if (![value isKindOfClass:NSString.class]) \
            value = [value description]; \
        field = [NSDecimalNumber decimalNumberWithString:value]; \
        dictionary[@#name] = nil; \
    } \
}

#define addDoubleField(field, name) { \
    NSNumber *value = dictionary[@#name]; \
    if ([value respondsToSelector:@selector(doubleValue)]) { \
        field = [value doubleValue]; \
        dictionary[@#name] = nil; \
    } \
}

+ (BranchUniversalObject*) universalObjectFromDictionary:(NSMutableDictionary*)dictionary {
    NSInteger initialCount = dictionary.count;
    if (initialCount == 0) return nil;

    /* Adobe product fields:
        product_id
        sku
        category
        name
        brand
        variant
        price
        quantity
        url
        image_url
    */

    BranchUniversalObject *object = [[BranchUniversalObject alloc] init];
    object.contentMetadata.contentSchema = BranchContentSchemaCommerceProduct;

    addStringField(object.canonicalIdentifier, product_id);
    addStringField(object.contentMetadata.sku, sku);
    BNCProductCategory category = [self categoryFromString:dictionary[@"category"]];
    if (category) {
        object.contentMetadata.productCategory = category;
        dictionary[@"category"] = nil;
    }
    addStringField(object.contentMetadata.productName, name);
    addStringField(object.contentMetadata.productBrand, brand);
    addStringField(object.contentMetadata.productVariant, variant);
    addDecimalField(object.contentMetadata.price, price);
    addDoubleField(object.contentMetadata.quantity, quantity);
    addStringField(object.canonicalUrl, url);
    addStringField(object.imageUrl,  image_url);

    // Adobe fields not handled: coupon and position, for instance.
    object.contentMetadata.customMetadata = [self stringDictionaryFromDictionary:dictionary];

    // If we didn't add any fields return a nil object:
    if (dictionary.count == initialCount)
        return nil;

    return object;
}

+ (NSString*) stringFromObject:(id<NSObject>)object {
    if (object == nil) return nil;
    if ([object isKindOfClass:NSString.class]) {
        return (NSString*) object;
    } else
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [(id)object stringValue];
    }
    return [object description];
}

+ (NSMutableDictionary*) stringDictionaryFromDictionary:(NSDictionary*)dictionary_ {
    if (dictionary_ == nil) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for(id<NSObject> key in dictionary_.keyEnumerator) {
        NSString* stringValue = [self stringFromObject:dictionary_[key]];
        NSString* stringKey = [self stringFromObject:key];
        if (stringKey) dictionary[stringKey] = stringValue;
    }
    return dictionary;
}

+ (BranchEvent*) branchEventFromAdbobeEvent:(NSString*)eventName
                                 dictionary:(NSDictionary*)immutableDictionary {
    // Make a deep copy of the event dictionary:
    NSError*error = nil;
    NSMutableDictionary*dictionary = nil;
    NSData*data = [NSPropertyListSerialization dataWithPropertyList:immutableDictionary
        format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (error || data == nil) {
        BNCLogWarning(@"Can't serialize event parameters: %@.", error);
    } else {
        error = nil;
        dictionary = [NSPropertyListSerialization propertyListWithData:data
            options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
        if (error) BNCLogWarning(@"Can't de-serialize event parameters: %@.", error);
    }

    // Make a BranchEvent from the passed dictionary:
    BranchEvent *event = [[BranchEvent alloc] initWithName:eventName];
    if (!dictionary) return event;

    /* BranchEvent fields:

    transactionID;
    currency;
    revenue;
    shipping;
    tax;
    coupon;
    affiliation;
    eventDescription;
    searchQuery;
    */

    /* Adobe event fields:

    "order_id": "50314b8e9bcf000000000000",
    "affiliation": "Google Store",
    "value": 30,
    "revenue": 25,
    "shipping": 3,
    "tax": 2,
    "discount": 2.5,
    "coupon": "hasbros",
    "currency": "USD",
    */

    addStringField(event.transactionID, order_id);
    addStringField(event.currency, currency);
    addDecimalField(event.revenue, revenue);
    addDecimalField(event.shipping, shipping);
    addDecimalField(event.tax, tax);
    addStringField(event.coupon, coupon);
    addStringField(event.affiliation, affiliation);
    event.eventDescription = eventName;
    addStringField(event.searchQuery, query);

    NSArray *products = dictionary[@"products"];
    if ([products isKindOfClass:NSArray.class]) {
        for (NSMutableDictionary *product in products) {
            BranchUniversalObject *object = [self universalObjectFromDictionary:product];
            if (object) [event.contentItems addObject:object];
        }
        dictionary[@"products"] = nil;
    }

    // Maybe the some product fields are at the first level. Don't add if we already have:
    if (event.contentItems.count == 0) {
        BranchUniversalObject *object = [self universalObjectFromDictionary:dictionary];
        if (object) [event.contentItems addObject:object];
    }

    // Add any extra fields to customData:
    event.customData = [self stringDictionaryFromDictionary:dictionary];

    return event;
}

- (void) trackEvent:(NSDictionary*)eventData {
    NSString*eventName = [eventData objectForKey:@"action"];
    if (!eventName.length) return;
    NSDictionary*content = [eventData objectForKey:@"contextdata"];
    BranchEvent*event = [self.class branchEventFromAdbobeEvent:eventName dictionary:content];
    [event logEvent];
}

@end
