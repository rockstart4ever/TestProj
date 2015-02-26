//
//  ResourcesViewController.m
//  Caravan
//
//  Created by Ravi Chaudhary on 22/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import "ResourcesViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ResourceModel.h"
#import "IconDownloader.h"

@interface ResourcesViewController ()

@end

@implementation ResourcesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Resources";
        
        //Download resources list
        [self downloadResources];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialization
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    //Create view
    [self setupView];
}

/*
 * @desc - Sets up the view by adding UI components to it
 */
-(void)setupView
{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate configureViewOfController:self];
    
    UITableView * tableView = [[UITableView alloc]initWithFrame: CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    //Set table footer view
    tableView.tableFooterView = [[UIView alloc] initWithFrame : CGRectZero];
    
//    //Create header view
//    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, kHeaderHeight)];
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, kHeaderHeight - 30, 320, 30)];
//    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    label.font = [UIFont fontWithName:kRegularFontName size:17.0f];
//    label.textColor = [UIColor whiteColor];
//    label.text = @" Resources";
//    [headerView addSubview:label];
//    
//    //Set table header view
//    tableView.tableHeaderView = headerView;
    tableView.backgroundColor = [UIColor clearColor];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    //Show progress indicator
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
}


-(void)downloadResources
{
	NSString * queryString = [[NSString alloc]initWithFormat:@"action=resource"];
    NSData * postData = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    //Create url
    NSURL * url = [NSURL URLWithString:kBaseApi];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //Set http method as POST
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:postData];
    
	//Create connection and start to download data
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//Create responseData to store the response
	NSMutableData * mutableData = [[NSMutableData alloc]init];
	responseData = mutableData;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//Append all of the response to the responseData object
	[responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//Convert JSON response into a dictionary object
	NSError * error;
	NSArray * response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
	
	if(response)
	{
		[self processResources:response];
    }
    else
    {
        //Show error message
        [self showAlert:@"Unknown Error"];
    }
    
    //Hide progress indicator
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //Hide progress indicator
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    
    if([error code]==-1009)
    {
        //Show error message
        [self showAlert:@"Network Unavailable"];
    }
    else
    {
        //Show error message
        [self showAlert:@"Network Unavailable"];
    }
}


-(void)processResources:(NSArray *)response
{
    NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
    for (NSDictionary * dict in response)
    {
        ResourceModel * resourceModel = [[ResourceModel alloc]init];
        resourceModel.resourceId = [dict objectForKey:@"id"];
        resourceModel.link = [dict objectForKey:@"url"];
        resourceModel.content = [dict objectForKey:@"content"];
        
        NSString * imageUrl = [dict objectForKey:@"image"];
        imageUrl = [imageUrl substringFromIndex:[imageUrl rangeOfString:@"src="].location+[@"src=" length]+1];
        imageUrl = [imageUrl substringToIndex:[imageUrl rangeOfString:@"class="].location-2];
        NSLog(@"ImageUrl -%@",imageUrl);
        resourceModel.imageUrl = imageUrl;
        
        [mutableArray addObject:resourceModel];
    }
    
    self.resourcesArray = mutableArray;
    [self.tableView reloadData];
}


-(void)showAlert:(NSString*)message
{
    //show alert and start sanning on ok tap
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK",nil];
    [alert show];
}


// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to cancel all outstanding downloads.
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.resourcesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        /*
         * Configure the cell
         */
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kCellX, (kResourceCellHeight - kResourceCellImageHeight)/2, kResourceCellImageWidth, kResourceCellImageHeight)];
        imageView.tag = kImageViewTag;
        [cell.contentView addSubview:imageView];
        
        UIView * v = [[UIView alloc] init];
    	v.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1];
    	cell.selectedBackgroundView = v;

        UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(2 * kCellX + kResourceCellImageWidth, kCellY, self.tableView.frame.size.width - kResourceCellImageWidth - 3 * kCellX, kResourceCellLinkLabelHeight)];
        textLabel.textColor = [UIColor orangeColor];
        textLabel.font = [UIFont fontWithName:kRegularFontName size:13.0f];
        textLabel.tag = kTextLabelTag;
        textLabel.backgroundColor = [UIColor clearColor];
//        textLabel.highlightedTextColor = [UIColor colorWithRed:60/255.0f green:187/255.0f blue:240/255.0f alpha:1];
        [cell.contentView addSubview:textLabel];
        
        textLabel = [[UILabel alloc]initWithFrame:CGRectMake(2 * kCellX + kResourceCellImageWidth, 2 * kCellY + kResourceCellLinkLabelHeight, self.tableView.frame.size.width - kResourceCellImageWidth - 3 * kCellX, kResourceCellHeight - kResourceCellLinkLabelHeight - 3 * kCellY)];
        textLabel.textColor = [UIColor grayColor];
        textLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        textLabel.numberOfLines = 3;
        textLabel.font = [UIFont fontWithName:kRegularFontName size:11.0f];
        textLabel.tag = kDetailLabelTag;
        textLabel.backgroundColor = [UIColor clearColor];
        //        textLabel.highlightedTextColor = [UIColor colorWithRed:60/255.0f green:187/255.0f blue:240/255.0f alpha:1];
        [cell.contentView addSubview:textLabel];
    }
    
    ResourceModel * resourceModel = [self.resourcesArray objectAtIndex:indexPath.row];
    
    UILabel * textLabel = (UILabel *)[cell.contentView viewWithTag:kTextLabelTag];
    textLabel.text = resourceModel.link;
    
    textLabel = (UILabel *)[cell.contentView viewWithTag:kDetailLabelTag];
    textLabel.text = resourceModel.content;
    
    UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
    
    // Only load cached images; defer new downloads until scrolling ends
    if (!resourceModel.resourceImage)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:resourceModel forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    else
    {
        imageView.image = resourceModel.resourceImage;
    }

    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kResourceCellHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResourceModel * resourceModel = [self.resourcesArray objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:resourceModel.link]];
}

#pragma mark - Table cell image support

/*
 *	@desc - Starts downloading icon at the url in resourceModel
 */
- (void)startIconDownload:(ResourceModel *)resourceModel forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage * image){
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            resourceModel.resourceImage = image;
            
            //Set image on cell
            UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
            imageView.image = resourceModel.resourceImage;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownload:resourceModel.imageUrl];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.resourcesArray.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            ResourceModel * resourceModel = self.resourcesArray[indexPath.row];
            
            if (!resourceModel.resourceImage)
                // Avoid the image download if the it already has an icon
            {
                [self startIconDownload:resourceModel forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
