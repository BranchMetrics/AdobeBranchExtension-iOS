//
//  BranchExtensionListener.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/26/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "BranchExtensionListener.h"

@implementation BranchExtensionListener

- (void) hear: (nonnull ADBExtensionEvent*) event {
    NSString* configuration = [self.extension.api
                               getSharedEventState:@"com.adobe.module.configuration" event:nil error:nil];
    if(configuration) {
        NSLog(@"The configuration when event \"%@\" was sent was:\n%@", [event eventName], configuration);
    }
}

@end
