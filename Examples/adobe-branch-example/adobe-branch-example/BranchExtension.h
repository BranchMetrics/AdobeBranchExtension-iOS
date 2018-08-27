//
//  BranchExtension.h
//
//  Created by Aaron Lopez on 8/14/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADBExtension.h"
#import "ADBExtensionEvent.h"
#import "ADBExtensionApi.h"

@interface BranchExtension : ADBExtension {}
- (void) configureSession;
- (void) onUnregister;
@end
