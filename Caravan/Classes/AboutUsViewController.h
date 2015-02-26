//
//  AboutUsViewController.h
//  Caravan
//
//  Created by Ravi Chaudhary on 21/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController
{
    NSMutableData * responseData;
}

@property(nonatomic, strong)UITextView * textView;
@property(nonatomic, strong)UIScrollView * scrollView;
@property(nonatomic, strong)UIActivityIndicatorView * activityIndicator;

@end
