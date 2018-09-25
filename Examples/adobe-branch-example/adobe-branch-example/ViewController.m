//
//  ViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "ViewController.h"
#import "ProductViewController.h"
#import <ACPCore_iOS/ACPCore_iOS.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    NSDictionary *productDictionary;
    NSArray *nameArray;
    NSArray *staticArray;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[ADBMobileMarketing analyticsTrackAction:@"HI" data:nil];
    
    productDictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                                          pathForResource:@"Products" ofType:@"plist"]isDirectory:NO]];
    // TODO'
    self.searchBar.delegate = self;
    
    //    staticArray = [productDictionary allKeys];
    //    nameArray = [productDictionary allKeys];
    staticArray = @[@"glasses", @"stickers"];
    nameArray = @[@"glasses", @"stickers"];
}

- (void)viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:<#animated#>];
//    searchBar.text = ""
//    filterTableView(text: "")
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *bPredicate =
    [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", searchText];
    
    nameArray = [staticArray filteredArrayUsingPredicate:bPredicate];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = staticArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[nameArray[indexPath.row] lowercaseString]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return nameArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductViewController *nextVC;
    nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
    nextVC.productData = @{@"productName": staticArray[indexPath.row]};
    [self.navigationController pushViewController:nextVC animated:YES];
    //    [navC pushViewController:nextVC animated:YES];
}

@end
