//
//  AdobeBranchExtensionConfig.h
//  Pods
//
//  Created by Ernest Cho on 4/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdobeBranchExtensionConfig : NSObject
@property (nonatomic, strong, readwrite) NSArray<NSString *> *eventTypes;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *eventSources;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *exclusionList;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *allowList;

+ (AdobeBranchExtensionConfig *)instance;

@end

NS_ASSUME_NONNULL_END
