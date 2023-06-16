//
//  ProductListViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import "ProductListViewController.h"
#import "Product.h"
#import "ProductViewController.h"
#import "TextViewController.h"
#import <AdobeBranchExtension/AdobeBranchExtension.h>

@interface ProductListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)   NSArray<Product*>*products;
@property (nonatomic, strong)   NSArray*events;
@property (nonatomic, weak)     IBOutlet UITableView *tableView;
@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView =
        [[UIImageView alloc]
            initWithImage:[UIImage imageNamed:@"Header"]];
    self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.products = [Product loadProducts];
    self.events = @[
        @"Add to Cart",
        @"View",
        @"Purchase"
    ];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:     return self.products.count;
    case 1:     return 1;
    case 2:     return self.events.count;
    }
    return self.products.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:     return @"Branch Swag";
    case 1:     return @"Short Links";
    case 2:     return @"Events";
    default:    return @"Program Error";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    switch (indexPath.section) {
    case 0: {
        Product*product = self.products[indexPath.row];
        cell.textLabel.text = product.name;
        cell.imageView.image = [UIImage imageNamed:product.imageName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        break;
    }
    case 1:
        cell.textLabel.text = @"Create Short Link";
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        break;
    case 2:
        cell.textLabel.text = self.events[indexPath.row];
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0: {
        ProductViewController *pvc =
            [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
        pvc.product = self.products[indexPath.row];
        [self.navigationController pushViewController:pvc animated:YES];
        break;
    }
    case 1: {
        BranchUniversalObject* branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier: @"https://branch.io/branch/Glasses.html"];
        branchUniversalObject.canonicalUrl = @"https://branch.io/branch/Glasses.html";
        branchUniversalObject.title = @"Branch Glasses";
        branchUniversalObject.contentDescription = @"Look stylish -- Branch style -- in these Branch sun glasses.";
        branchUniversalObject.imageUrl = @"https://cdn.branch.io/branch-assets/1538165719615-og_image.jpeg";
        branchUniversalObject.contentMetadata.customMetadata[@"imageName"] = @"glasses";
        
        BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
        linkProperties.feature = @"Sharing";
        linkProperties.tags = @[@"Swag", @"Branch"];
        [linkProperties addControlParam:@"$desktop_url" withValue:  @"https://branch.io/branch/Glasses.html"];
        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            [self showCreatedLink:url];
        }];
        break;
    }
    case 2: {
        NSString*eventName = [self.events[indexPath.row] uppercaseString];
        eventName = [eventName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [AEPMobileCore trackAction:eventName data:@{
            @"name":            @"Branch Sunglasses",
            @"revenue":         @"200.00",
            @"currency":        @"USD",
            @"transaction_id":  @"C000F1F7-D8DA-4C31-9049-93B57BF788ED",
            @"timestamp":       [NSDate date].description,
            @"category":        @"Apparel & Accessories",
            @"sku":             @"sku-bee-doo",
        }];
        break;
    }}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) showCreatedLink:(NSString*)url {
    TextViewController*tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewController"];
    [tvc loadViewIfNeeded];
    tvc.title = @"Branch Link";
    tvc.titleLabel.text = @"Branch Short Link";
    tvc.textView.text = url;
    [self.navigationController pushViewController:tvc animated:YES];
}

@end
