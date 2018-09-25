//
//  ProductViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/25/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "ProductViewController.h"
#import "BranchConfig.h"
#import <ACPCore_iOS/ACPCore.h>
#import <ACPCore_iOS/ACPExtensionEvent.h>


@interface ProductViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.productData != nil) {
        self.productTitle.text = self.productData[@"productName"];
        self.productImage.image = [UIImage imageNamed:[self.productData[@"productName"] lowercaseString]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareButton:(id)sender {
    NSError* error = nil;
    ACPExtensionEvent* shareSheetEvent = [ACPExtensionEvent extensionEventWithName:@"branch-share-sheet"
                                                                        type:BRANCH_EVENT_TYPE_SHARE_SHEET
                                                                      source:BRANCH_EVENT_SOURCE_STANDARD
                                                                        data:nil
                                                                       error:&error];
    
    if ([ACPCore dispatchEvent:shareSheetEvent error:&error]) {
        NSLog(@"Error dispatching event %@:%ld", [error domain], [error code]);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
