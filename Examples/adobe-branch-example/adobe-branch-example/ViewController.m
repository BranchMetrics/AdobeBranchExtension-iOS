//
//  ViewController.m
//  adobe-branch-example
//
//  Created by Aaron Lopez on 8/13/18.
//  Copyright © 2018 Aaron Lopez. All rights reserved.
//

#import "ViewController.h"
#import <ACPCore_iOS/ACPCore_iOS.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[ADBMobileMarketing analyticsTrackAction:@"HI" data:nil];
    
    [ACPCore trackAction:@"action name" data:@{@"key":@"value"}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
