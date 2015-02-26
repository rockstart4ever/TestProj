//  MenuTableViewController.h


#import <UIKit/UIKit.h>

@interface MenuTableViewController : UITableViewController
{
    NSArray * topItems;
    NSArray * subItems;
    NSDictionary * dictionary;

    NSInteger currentExpandedIndex;
}

@end
