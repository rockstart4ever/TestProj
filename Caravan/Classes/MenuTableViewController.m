//  MenuTableViewController.m

#import "MenuTableViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import <PKRevealController.h>
#import "ResourcesViewController.h"
#import "AboutUsViewController.h"
#import "RecipesViewController.h"
#import "VideosViewController.h"
#import "ContactUsViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"MenuItems" ofType:@"plist"];
        dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        topItems = [dictionary allKeys];
        currentExpandedIndex = -1;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.revealController setMinimumWidth:10.0f maximumWidth:20.0f forViewController:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Configure UI
    
    self.tableView.backgroundColor = [UIColor colorWithRed:58/255.0f green:53/255.0f blue:53/255.0f alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;


    
//    self.view.backgroundColor = [UIColor colorWithRed:116.0f/255.0f green:71.0f/255.0f blue:8.0f/255.0f alpha:1];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
//    self.tableView.separatorColor = [UIColor colorWithRed:116.0f/255.0f green:71.0f/255.0f blue:8.0f/255.0f alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [topItems count] + ((currentExpandedIndex > -1) ? [subItems count] : 0);

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [subItems count];
    
    UITableViewCell *cell;
    NSString * cellIdentifier = isChild ? ParentCellIdentifier : ChildCellIdentifier;

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIImageView * separatorImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Separator.png"]];
        separatorImageView.frame = CGRectMake(0, 38, 320, 2);
        [cell.contentView addSubview:separatorImageView];
        
        UIView * v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor clearColor];
    	cell.selectedBackgroundView = v;
        
        UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCellX, (kMenuTableCellHeight - 25)/2 - 1, 300, 25)];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.tag = 11;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.highlightedTextColor = [UIColor colorWithRed:60/255.0f green:187/255.0f blue:240/255.0f alpha:1];
        [cell.contentView addSubview:textLabel];

    }
    
    //Get text label
    UILabel * textLabel = (UILabel *)[cell.contentView viewWithTag:11];
    
    //If this is child cell
    if (isChild) {
        cell.backgroundColor = [UIColor colorWithRed:51/255.0f green:47/255.0f blue:47/255.0f alpha:1];
        textLabel.font = [UIFont fontWithName:kRegularFontName size:14.0f];
        textLabel.text = [subItems objectAtIndex:indexPath.row - currentExpandedIndex - 1];
    }
    else {
        
        cell.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont fontWithName:kRegularFontName size:17.0f];
        
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex)
        ? indexPath.row - [subItems count]
        : indexPath.row;

//        cell.contentView.backgroundColor = [UIColor colorWithRed:154.0f/255.0f green:85.0f/255.0f blue:10.0f/255.0f alpha:1];
        textLabel.text = [topItems objectAtIndex:topIndex];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMenuTableCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [subItems count];
    
    return 100;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChild =
    currentExpandedIndex > -1
    && indexPath.row > currentExpandedIndex
    && indexPath.row <= currentExpandedIndex + [subItems count];
    
    if (isChild) {
        NSLog(@"A child was tapped");
        [self itemSelectedAtRow:currentExpandedIndex];
    }
    else
    {
        [self.tableView beginUpdates];
        
        if (currentExpandedIndex == indexPath.row) {
            [self collapseSubItemsAtIndex:currentExpandedIndex];
            currentExpandedIndex = -1;
        }
        else {
            
            NSInteger newCurrentExpandedIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex) ? indexPath.row - [subItems count] : indexPath.row;
            NSArray * newSubItems = [dictionary objectForKey:[topItems objectAtIndex:newCurrentExpandedIndex]];
            
            if([newSubItems count] > 0)
            {
                BOOL shouldCollapse = currentExpandedIndex > -1;

                if (shouldCollapse) {
                    [self collapseSubItemsAtIndex:currentExpandedIndex];
                }
                
                currentExpandedIndex = newCurrentExpandedIndex;
                
                subItems = newSubItems;
                
                [self expandItemAtIndex:currentExpandedIndex];
            }
            else
            {
                //This is atomic item. Perform action.
                NSLog(@"Atomic item was tapped");
                [self itemSelectedAtRow:newCurrentExpandedIndex];
            }
        }
        
        [self.tableView endUpdates];
    }
    
}

-(void)itemSelectedAtRow : (NSInteger)row
{
    // For Home screen
    switch (row) {
        case 0:
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if (![((UINavigationController *)(self.revealController.frontViewController)).topViewController isKindOfClass:[AboutUsViewController class]])
            {
                AboutUsViewController * aboutUsViewController = [[AboutUsViewController alloc] init];
                UINavigationController * navigationController = [[UINavigationController alloc]initWithRootViewController:aboutUsViewController];
                
                [self.revealController setFrontViewController:navigationController];
                
            }
            
            break;
        case 1:
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if (![((UINavigationController *)(self.revealController.frontViewController)).topViewController isKindOfClass:[RecipesViewController class]])
            {
                RecipesViewController * recipesViewController = [[RecipesViewController alloc] init];
                UINavigationController * navigationController = [[UINavigationController alloc]initWithRootViewController:recipesViewController];
                
                [self.revealController setFrontViewController:navigationController];
                
            }
            break;
        case 2:
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if (![((UINavigationController *)(self.revealController.frontViewController)).topViewController isKindOfClass:[ResourcesViewController class]])
            {
                ResourcesViewController * resourcesViewController = [[ResourcesViewController alloc] init];
                UINavigationController * navigationController = [[UINavigationController alloc]initWithRootViewController:resourcesViewController];
                
                [self.revealController setFrontViewController:navigationController];
                
            }
            
            break;
        case 3:
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if (![((UINavigationController *)(self.revealController.frontViewController)).topViewController isKindOfClass:[VideosViewController class]])
            {
                VideosViewController * videosViewController = [[VideosViewController alloc] init];
                UINavigationController * navigationController = [[UINavigationController alloc]initWithRootViewController:videosViewController];
                
                [self.revealController setFrontViewController:navigationController];
                
            }
            break;
        case 4:
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if (![((UINavigationController *)(self.revealController.frontViewController)).topViewController isKindOfClass:[ContactUsViewController class]])
            {
                ContactUsViewController * contactUsViewController = [[ContactUsViewController alloc] init];
                UINavigationController * navigationController = [[UINavigationController alloc]initWithRootViewController:contactUsViewController];
                
                [self.revealController setFrontViewController:navigationController];
                
            }
            break;

        default:
            break;
    }
    
    //Toggle reveal
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [delegate revealToggle];
}

/*
{
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        NSInteger row = indexPath.row;
        
        //    NSDictionary * itemDict = [_itemsArray objectAtIndex:row];
        //    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        //    UIImageView * imageView = (UIImageView *)[[cell.contentView viewWithTag:10];
        //	imageView.image = [UIImage imageNamed:[itemDict objectForKey:@"Image"]];
        
        // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
        SWRevealViewController *revealController = self.revealViewController;
        
        // We know the frontViewController is a NavigationController
        GlobalNavigationController * frontNavigationController = (id)revealController.frontViewController;  // <-- we know it is a NavigationController
        
        // For Home screen
        if (row == 0)
        {
            // Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.
            if ( ![frontNavigationController.topViewController isKindOfClass:[HomeViewController class]])
            {
                //Cancel all the running connections on front ravigation controller
                [self cancelAllRunningConnectionsOn:frontNavigationController];
                
                HomeViewController * homeViewController = [[HomeViewController alloc] init];
                homeViewController.pageTitle = kHomeScreenTitle;
                GlobalNavigationController * navigationController = [[GlobalNavigationController alloc] initWithRootViewController:homeViewController];
                [navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
                [self.revealViewController setFrontViewController:navigationController animated:YES];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            else
            {
                [revealController revealToggle:self];
            }
        }
        
        // For Favorite screen
        else if (row == 1)
        {
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            if ( [frontNavigationController.topViewController isKindOfClass:[ListViewController class]] && (((ListViewController *)frontNavigationController.topViewController).pageType == PlaceSearchPageTypeFavorites))
            {
                [revealController revealToggle:self];
            }
            // Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.
            else
            {
                //Cancel all the running connections on front ravigation controller
                [self cancelAllRunningConnectionsOn:frontNavigationController];
                
                ListViewController * favoriteViewController = [[ListViewController alloc] initWithPageType:PlaceSearchPageTypeFavorites placeDictionary:nil searchKeyword:nil];
                favoriteViewController.pageTitle = kFavoriteScreenTitle;
                GlobalNavigationController * navigationController = [[GlobalNavigationController alloc] initWithRootViewController:favoriteViewController];
                [navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
                [self.revealViewController setFrontViewController:navigationController animated:YES];
            }
        }
        // For Settings screen
        else if (row == 2)
        {
            // Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.
            if ( ![frontNavigationController.topViewController isKindOfClass:[SettingsViewController class]] )
            {
                //Cancel all the running connections on front ravigation controller
                [self cancelAllRunningConnectionsOn:frontNavigationController];
                
                SettingsViewController * settingsViewController = [[SettingsViewController alloc] init];
                settingsViewController.pageTitle = kSettingsScreenTitle;
                GlobalNavigationController * navigationController = [[GlobalNavigationController alloc] initWithRootViewController:settingsViewController];
                [navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
                [self.revealViewController setFrontViewController:navigationController animated:YES];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            else
            {
                [revealController revealToggle:self];
            }
        }
    }
}
*/
- (void)expandItemAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray array];
    int insertPos = index + 1;
    for (int i = 0; i < [subItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(int)index {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = index + 1; i <= index + [subItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
