//
//  ProductViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/25/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "ProductViewController.h"
#import "Product.h"
#import <ACPCore_iOS/ACPCore_iOS.h>
#import <AdobeBranchExtension/AdobeBranchExtension.h>

@interface ProductViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel     *productTitle;
@property (weak, nonatomic) IBOutlet UIButton    *shareButton;
@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productImage.image = [UIImage imageNamed:self.product.imageName];
    self.productTitle.text = self.product.name;
    [ACPCore trackAction:@"VIEW" data:@{
        @"name":        self.product.name,
        @"revenue":     @"200.0",
        @"currency":    @"USD"
    }];
}

- (IBAction)shareButton:(id)sender {
    NSError* error = nil;
    ACPExtensionEvent* shareSheetEvent =
        [ACPExtensionEvent extensionEventWithName:@"branch-share-sheet"
            type:BRANCH_EVENT_TYPE_SHARE_SHEET
            source:BRANCH_EVENT_SOURCE_STANDARD
            data:@{
                @"title": self.product.name,
                @"summary": self.product.summary,
                @"image_url": self.product.imageURL,
                @"url": self.product.URL,
            }
            error:&error];
    
    if ([ACPCore dispatchEvent:shareSheetEvent error:&error]) {
        NSLog(@"Can't dispatch event: %@.", error);
    }
}

@end
