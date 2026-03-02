//
//  AdobeBranchExtensionConfig.m
//  Pods
//
//  Created by Ernest Cho on 4/11/19.
//

#import "AdobeBranchExtensionConfig.h"

@implementation AdobeBranchExtensionConfig

+ (AdobeBranchExtensionConfig *)instance {
    static AdobeBranchExtensionConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [AdobeBranchExtensionConfig new];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // default event type and source to track, client can override
        self.eventTypes = @[ @"com.adobe.eventType.generic.track" ];
        self.eventSources = @[ @"com.adobe.eventSource.requestContent" ];
        self.exclusionList = [NSArray new];
        self.allowList = [NSArray new];
    }
    return self;
}

@end
