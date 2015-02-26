//
//  ResourcesViewController.h
//  Caravan
//
//  Created by Ravi Chaudhary on 22/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourcesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableData * responseData;
}
@property(nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSArray * resourcesArray;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@end
