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
#import "IconDownloader.h"

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
    for (NSInteger i = 0; i < [response count]; i++)
    {
        NSDictionary * dict = [response objectAtIndex:0];
        
        VideoDataModel * videoDataModel = [[VideoDataModel alloc]init];
        videoDataModel.frameElement = [dict objectForKey:@"video"];
        videoDataModel.content = [dict objectForKey:@"videocontent"];
        
        /*
         * Fetch video url and video id from the frameElement
         */
        NSString * videoUrl = [NSString stringWithFormat:@"%@", videoDataModel.frameElement];
        videoUrl = [videoUrl substringFromIndex:[videoUrl rangeOfString:@"src="].location+[@"src=" length]+1];
        videoUrl = [videoUrl substringToIndex:[videoUrl rangeOfString:@"\""].location];
        if([videoUrl rangeOfString:@"http:"].location == NSNotFound)
        {
            videoUrl = [NSString stringWithFormat:@"http:%@", videoUrl];
        }
        NSLog(@"VideoUrl -%@",videoUrl);
        videoDataModel.url = videoUrl;
        
        NSString * videoId = [videoUrl substringFromIndex:[videoUrl rangeOfString:@"embed/"].location+[@"embed/" length]];
        videoDataModel.videoId = videoId;
        
        //Add videoDataModel object to array
        [mutableArray addObject:videoDataModel];
    }
    
    //Videos array formed
    self.videosArray = mutableArray;
    
    //Now show videos on view
    [self showVideosOnView];
}

-(void)showVideosOnView
{
    CGFloat itemWidth = (self.scrollView.frame.size.width - 2 * kMarginBetweenVideoItems - (kNumberOfVideosInRow - 1)*kMarginBetweenVideoItems) / kNumberOfVideosInRow;
    CGFloat x = kMarginBetweenVideoItems;
    CGFloat y = kMarginBetweenVideoItems;
    
    for (NSInteger i = 0; i < [self.videosArray count]; i++) {

        VideoDataModel * videoDataModel = [self.videosArray objectAtIndex:i];

        //Create video view
        UIView * videoView = [self videoTileViewWithFrame:CGRectMake(x, y, itemWidth, itemWidth)];
        
        //Set tag
        videoView.tag = i;
        
        //Set video content on videoView's label
        UILabel * label = (UILabel *)[videoView viewWithTag:kTextLabelTag];
        label.text = videoDataModel.content;
        
        //Set video content on videoView's label
        NSString * iconUrl = [NSString stringWithFormat:@"%@%@/default.jpg", kYouTubeImageApi, videoDataModel.videoId];
        NSLog(@"%@", iconUrl);
        [self startIconDownload:iconUrl forItem:i];
        
        
        [self.scrollView addSubview:videoView];
        
        if((i+1) % kNumberOfVideosInRow == 0)
        {
            x = kMarginBetweenVideoItems;
            y += itemWidth + kMarginBetweenVideoItems;
        }
        else
        {
            x += itemWidth + kMarginBetweenVideoItems;
        }
    }
    
    CGFloat contentHeight = (x == kMarginBetweenVideoItems) ?  y : (y + itemWidth + kMarginBetweenVideoItems);
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, contentHeight)];
}

/*
 * @desc - Creates view for video tile with specified frame
 * @param - frame
 */
-(UIView *)videoTileViewWithFrame : (CGRect)frame
{
    UIView * videoView = [[UIView alloc]initWithFrame:frame];
    videoView.backgroundColor = [UIColor whiteColor];

    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kVideoImageViewPadding, kVideoImageViewPadding, frame.size.width - 2 * kVideoImageViewPadding, frame.size.height - 2 * kVideoImageViewPadding - kVideoContentLabelHeight)];
    imageView.tag = kImageViewTag;
    imageView.image = [UIImage imageNamed:@"video.png"];
    [videoView addSubview:imageView];
    
    UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(kVideoImageViewPadding, frame.size.height - kVideoContentLabelHeight - 2, frame.size.width - 2 * kVideoImageViewPadding, kVideoContentLabelHeight)];
    textLabel.tag = kTextLabelTag;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:1];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont fontWithName:kRegularFontName size:11.0f];
    textLabel.text = @"This is a video. This is a video. This is a video. This is a video. This is a video";
    [videoView addSubview:textLabel];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = imageView.frame;
    [button setImage:[UIImage imageNamed:@"PlayIcon.png"] forState:UIControlStateNormal];
    [videoView addSubview:button];
    
    return videoView;
}


/*
 *	@desc - Starts downloading icon at the url in resourceModel
 */
- (void)startIconDownload:(NSString *)iconUrl forItem:(NSInteger)itemTag
{
    IconDownloader * iconDownloader = [[IconDownloader alloc] init];
    [iconDownloader setCompletionHandler:^(UIImage * image){
        
        UIView * videoView = [self.scrollView viewWithTag:itemTag];
        
        if(videoView)
        {
            UIImageView * imageView = (UIImageView *)[videoView viewWithTag:kImageViewTag];
            imageView.image = image;
        }
        
    }];
    [iconDownloader startDownload:iconUrl];
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
