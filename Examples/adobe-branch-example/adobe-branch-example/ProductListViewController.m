//
//  ProductListViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "ProductListViewController.h"
#import "Product.h"
#import "ProductViewController.h"
#import <ACPCore_iOS/ACPCore_iOS.h>

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
    //[ADBMobileMarketing analyticsTrackAction:@"HI" data:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:     return self.products.count;
    case 1:     return self.events.count;
    }
    return self.products.count;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:     return @"Branch Swag";
    case 1:     return @"Events";
    default:    return @"Program Error";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.section == 0) {
        Product*product = self.products[indexPath.row];
        cell.textLabel.text = product.name;
        cell.imageView.image = [UIImage imageNamed:product.imageName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = self.events[indexPath.row];
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ProductViewController *nextVC;
        nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
        nextVC.product = self.products[indexPath.row];
        [self.navigationController pushViewController:nextVC animated:YES];
    } else
    if (indexPath.section == 1) {
        NSString*eventName = [self.events[indexPath.row] uppercaseString];
        eventName = [eventName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [ACPCore trackAction:eventName data:@{
            @"name":        @"Branch Sunglasses",
            @"revenue":     @"200.00",
            @"currency":    @"USD",
            @"timestamp":   [NSDate date].description,
            @"category":    @"Apparel & Accessories",
            @"sku":         @"sku-bee-doo",
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
