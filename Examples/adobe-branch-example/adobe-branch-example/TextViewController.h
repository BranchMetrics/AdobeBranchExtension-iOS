//
//  TextViewController.h
//  adobe-branch-example
//
//  Created by Edward on 11/28/18.
//  Copyright © 2018 Branch Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel*titleLabel;
@property (nonatomic, weak) IBOutlet UITextView*textView;
@end

NS_ASSUME_NONNULL_END
