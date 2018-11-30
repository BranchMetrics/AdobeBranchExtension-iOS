//
//  Product.h
//  adobe-branch-example
//
//  Created by Edward Smith on 11/14/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Product : NSObject
@property (nonatomic, strong) NSString*name;
@property (nonatomic, strong) NSString*summary;
@property (nonatomic, strong) NSString*imageName;
@property (nonatomic, strong) NSString*URL;
@property (nonatomic, strong) NSString*imageURL;

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
+ (NSArray<Product*>*) loadProducts;
@end

NS_ASSUME_NONNULL_END
