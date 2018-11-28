//
//  BranchExtensionListener.m
//  AdobeBranchExtension
//
//  Created by Aaron Lopez on 8/26/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import "AdobeBranchExtension.h"
#import <Branch/Branch.h>

@implementation AdobeBranchExtensionListener

- (void) hear:(ACPExtensionEvent*)event {
    BNCLogDebug(@"Event: %@", event);
    AdobeBranchExtension*branchExtension = (AdobeBranchExtension*) self.extension;
    if (![branchExtension isKindOfClass:AdobeBranchExtension.class]) {
        BNCLogDebug(@"Skipping: Parent extension is of type %@.", NSStringFromClass(branchExtension.class));
        return;
    }
    [branchExtension handleEvent:event];
    [super hear:event];
}

@end
