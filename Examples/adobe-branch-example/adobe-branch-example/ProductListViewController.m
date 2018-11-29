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
#import <ACPCore_iOS/ACPCore_iOS.h>
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

    // Listen for deep links:
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(showDeepLinkNotification:)
        name:ABEBranchDeepLinkNotification
        object:nil];

    // Listen for deep links a different way:
    NSError*error = nil;
    ACPExtensionEvent* deepLinkListenerEvent =
        [ACPExtensionEvent extensionEventWithName:@"branch-deep-link-listener"
            type:ABEBranchEventType
            source:[NSBundle mainBundle].bundleIdentifier
            data:@{}
            error:&error];
    if (error) {
        NSLog(@"Error create event: %@.", error);
        return;
    }
    [ACPCore dispatchEventWithResponseCallback:deepLinkListenerEvent
        responseCallback:^ (ACPExtensionEvent*responseEvent) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self showCreatedLink:responseEvent];
            });
        }
        error:&error];
    if (error) {
        NSLog(@"Error dispatching event: %@.", error);
    }
}

- (void) showDeepLinkNotification:(NSNotification*)notification {
    NSDictionary*data = notification.userInfo;
    Product*product = Product.new;
    product.name        = data[ABEBranchLinkTitleKey];
    product.summary     = data[ABEBranchLinkSummaryKey];
    product.imageName   = data[ABEBranchLinkUserInfoKey][@"imageName"];
    product.URL         = data[ABEBranchLinkCanonicalURLKey];
    product.imageURL    = data[ABEBranchLinkImageURLKey];

    ProductViewController *pvc =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
    pvc.title = product.name;
    pvc.product = product;
    [self.navigationController pushViewController:pvc animated:YES];
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
        NSError*error = nil;
        ACPExtensionEvent* createLinkEvent =
            [ACPExtensionEvent extensionEventWithName:ABEBranchEventNameCreateDeepLink
                type:ABEBranchEventType
                source:[NSBundle mainBundle].bundleIdentifier
                data:@{
                    ABEBranchLinkTitleKey:          @"Branch Glasses",
                    ABEBranchLinkSummaryKey:        @"Look stylish -- Branch style -- in these Branch sun glasses.",
                    ABEBranchLinkImageURLKey:       @"https://cdn.branch.io/branch-assets/1538165719615-og_image.jpeg",
                    ABEBranchLinkCanonicalURLKey:   @"https://branch.io/branch/Glasses.html",
                    ABEBranchLinkCampaignKey:       @"Adobe",
                    ABEBranchLinkTagsKey:           @[ @"Swag", @"Branch"],
                    ABEBranchLinkUserInfoKey: @{
                        @"imageName":   @"glasses",
                        @"linkDate":    [NSDate date].description
                    }
                }
                error:&error];
        if (error) {
            NSLog(@"Error create event: %@.", error);
            return;
        }
        [ACPCore dispatchEventWithResponseCallback:createLinkEvent
            responseCallback:^ (ACPExtensionEvent*responseEvent) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    [self showCreatedLink:responseEvent];
                });
            }
            error:&error];
        if (error) {
            NSLog(@"Error dispatching event: %@.", error);
        }
        break;
    }
    case 2: {
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
        break;
    }}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) showCreatedLink:(ACPExtensionEvent*)responseEvent {
    TextViewController*tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewController"];
    [tvc loadViewIfNeeded];
    tvc.title = @"Branch Link";
    tvc.titleLabel.text = @"Branch Short Link";
    tvc.textView.text = responseEvent.eventData[ABEBranchLinkKey];
    [self.navigationController pushViewController:tvc animated:YES];
}

@end
