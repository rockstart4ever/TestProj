//
//  VideosViewController.m
//  Caravan
//
//  Created by Ravi Chaudhary on 21/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import "VideosViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "VideoDataModel.h"

@interface VideosViewController ()

@end

@implementation VideosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Download videos
        [self downloadVideos];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //Create view
    [self setupView];
    
    [self processVideos:nil];
    [self showVideosOnView];
}

/*
 * @desc - Sets up the view by adding UI components to it
 */
-(void)setupView
{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate configureViewOfController:self];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [self.view addSubview:self.scrollView];
}


-(void)downloadVideos
{
	NSString * queryString = [[NSString alloc]initWithFormat:@"action=video"];
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
		[self processVideos:response];
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


-(void)processVideos:(NSArray *)response
{
    /*
     * Process videos data and form an array containing all videos data
     */
    NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 11; i++)
    {
        //NSDictionary * dict = [response objectAtIndex:0];
        
        VideoDataModel * videoDataModel = [[VideoDataModel alloc]init];
//        videoDataModel.videoId = [dict objectForKey:@"id"];
        videoDataModel.frameElement = @"<iframe width='100%' height='100%' src='http://www.youtube.com/embed/IZLOO60S9Ic' frameborder='0' allowfullscreen></iframe>"; //[dict objectForKey:@"video"];
//        videoDataModel.content = [dict objectForKey:@"videocontent"];
        
//        NSString * videoUrl = [NSString stringWithFormat:@"%@", videoDataModel.frameElement];
//        videoUrl = [videoUrl substringFromIndex:[videoUrl rangeOfString:@"src="].location+[@"src=" length]+1];
//        videoUrl = [videoUrl substringToIndex:[videoUrl rangeOfString:@"frameborder="].location-2];
//        NSLog(@"VideoUrl -%@",videoUrl);
//        videoDataModel.url = videoUrl;
        
        [mutableArray addObject:videoDataModel];
    }
    
    self.videosArray = mutableArray;
    
    //Show videos on view
    [self showVideosOnView];
}

-(void)showVideosOnView
{
    CGFloat itemWidth = (self.scrollView.frame.size.width - (kNumberOfVideosInRow - 1)*kMarginBetweenVideoItems) / kNumberOfVideosInRow;
    CGFloat x = 0;
    CGFloat y = 0;
    
    for (NSInteger i = 0; i < [self.videosArray count]; i++) {

        VideoDataModel * videoDataModel = [self.videosArray objectAtIndex:i];
        
        UIWebView * webView = [[UIWebView alloc]initWithFrame:CGRectMake(x, y, itemWidth, itemWidth)];
        [webView loadHTMLString:videoDataModel.frameElement baseURL:nil];
        [self.scrollView addSubview:webView];
        
        if((i+1) % kNumberOfVideosInRow == 0)
        {
            x = 0;
            y += itemWidth + kMarginBetweenVideoItems;
        }
        else
        {
            x += itemWidth + kMarginBetweenVideoItems;
        }
    }
}

-(void)showAlert:(NSString*)message
{
    //show alert and start sanning on ok tap
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK",nil];
    [alert show];
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
