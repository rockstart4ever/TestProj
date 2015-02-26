//
//  VideosViewController.h
//  Caravan
//
//  Created by Ravi Chaudhary on 21/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideosViewController : UIViewController
{
    NSMutableData * responseData;
}

@property(nonatomic, strong) UIScrollView * scrollView;
@property(nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong) NSArray * videosArray;


@end
