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
@property (nonatomic, weak)     IBOutlet UITableView *tableView;
@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.products = [Product loadProducts];
    //[ADBMobileMarketing analyticsTrackAction:@"HI" data:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    Product*product = self.products[indexPath.row];
    cell.textLabel.text = product.name;
    cell.imageView.image = [UIImage imageNamed:product.imageName];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Branch Swag";
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductViewController *nextVC;
    nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
    nextVC.product = self.products[indexPath.row];
    [self.navigationController pushViewController:nextVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
