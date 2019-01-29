//
//  ProductViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 9/25/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import "ProductViewController.h"
#import "Product.h"
#import <AdobeBranchExtension/AdobeBranchExtension.h>

@interface ProductViewController () <BranchShareLinkDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel     *productTitle;
@property (weak, nonatomic) IBOutlet UIButton    *shareButton;
@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productImage.image = [UIImage imageNamed:self.product.imageName];
    self.productImage.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.productImage.layer.borderWidth = 2.0f;
    self.productImage.layer.cornerRadius = 5.0f;
    self.productImage.layer.masksToBounds = YES;
    self.productTitle.text = self.product.name;
    [ACPCore trackState:@"VIEW" data:@{
        @"name":        self.product.name,
        @"revenue":     @"200.0",
        @"currency":    @"USD"
    }];
}

- (IBAction)shareButton:(id)sender {
    [ACPCore trackAction:@"Share Button Pressed" data:@{
        @"name":        self.product.name,
        @"revenue":     @"200.0",
        @"currency":    @"USD"
    }];

    BranchUniversalObject* branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:self.product.URL];
    branchUniversalObject.canonicalUrl = self.product.URL;
    branchUniversalObject.title = self.product.name;
    branchUniversalObject.contentDescription = self.product.summary;
    branchUniversalObject.imageUrl = self.product.imageURL;
    branchUniversalObject.contentMetadata.customMetadata[@"image_name"] = self.product.imageName;
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"Sharing";
    linkProperties.tags = @[@"Swag", @"Branch"];

    [linkProperties addControlParam:@"$desktop_url" withValue: self.product.URL];
    
    BranchShareLink *shareLink = [[BranchShareLink alloc] initWithUniversalObject:branchUniversalObject linkProperties:linkProperties];
    
    shareLink.title = @"Check out this Branch swag!";
    shareLink.delegate = self;
    shareLink.shareText = @"Shared from Branch's Adobe TestBed.";
    
    [shareLink presentActivityViewControllerFromViewController:self anchor:sender];
}

- (void) branchShareLink:(BranchShareLink*)shareLink didComplete:(BOOL)completed withError:(NSError*)error {
    if (error != nil) {
        NSLog(@"Branch: Error while sharing! Error: %@.", error);
    } else if (completed) {
        NSLog(@"Branch: User completed sharing to channel '%@'.", shareLink.linkProperties.channel);
    } else {
        NSLog(@"Branch: User cancelled sharing.");
    }
}

@end
