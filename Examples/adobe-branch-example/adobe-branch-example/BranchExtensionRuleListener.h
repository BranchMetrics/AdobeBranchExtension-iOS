//
//  BranchExtensionRuleListener.h
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore_iOS/ACPCore_iOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface BranchExtensionRuleListener : ACPExtensionListener
- (void) showShareSheet:(nonnull NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END
