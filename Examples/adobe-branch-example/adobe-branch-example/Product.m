//
//  Product.m
//  adobe-branch-example
//
//  Created by Edward Smith on 11/14/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype) initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (!self) return self;
    self.name = dictionary[@"name"] ?: @"";
    self.summary = dictionary[@"summary"] ?: @"";
    self.imageName = dictionary[@"image"] ?: @"";
    self.imageURL = dictionary[@"image_url"] ?: @"";
    self.URL = dictionary[@"url"] ?: @"";
    return self;
}

+ (NSArray<Product*>*) loadProducts {
    NSError*error = nil;
    NSBundle*bundle = [NSBundle bundleForClass:self.class];
    NSURL*url = [bundle URLForResource:@"Products" withExtension:@"json"];
    NSData*data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (data == nil || error != nil) return NSArray.new;

    NSArray*array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (array == nil || error != nil) return NSArray.new;

    NSMutableArray*result = NSMutableArray.new;
    for (NSDictionary*d in array) {
        Product*p = [[Product alloc] initWithDictionary:d];
        if (p) [result addObject:p];
    }
    return result;
}

@end
