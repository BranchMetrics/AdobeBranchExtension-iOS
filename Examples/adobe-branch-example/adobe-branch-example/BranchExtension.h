//
//  BranchExtension.h
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ADBExtension.h"
//#import "ADBExtensionEvent.h"
//#import "ADBExtensionApi.h"
#import <ACPCore_iOS/ACPCore.h>
#import <ACPCore_iOS/ACPExtension.h>
#import <ACPCore_iOS/ACPExtensionEvent.h>
#import <ACPCore_iOS/ACPExtensionApi.h>

extern NSString * const branchEventTypeInit;

@interface BranchExtension : ACPExtension {}
- (void) onUnregister;
@end
