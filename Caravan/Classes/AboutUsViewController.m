//
//  AboutUsViewController.m
//  Caravan
//
//  Created by Ravi Chaudhary on 21/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import "AboutUsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Set title
        self.title = @"About Us";
        
        //download about contents
        [self downloadAboutContents];
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
    
    UITextView * textView = [[UITextView alloc]initWithFrame: CGRectMake(10, 10, self.scrollView.frame.size.width - 20, self.scrollView.frame.size.height - 20)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.editable = NO;
    [textView setUserInteractionEnabled:NO];
    textView.textColor = [UIColor orangeColor];
    textView.font = [UIFont fontWithName:kRegularFontName size:15.0f];
    self.textView = textView;
    [self.scrollView addSubview:self.textView];
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    //Show progress indicator
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
}


-(void)downloadAboutContents
{
 	NSString * queryString = [[NSString alloc]initWithFormat:@"action=about"];
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
		[self processData:response];
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

-(void)showAlert:(NSString*)message
{
    //show alert and start sanning on ok tap
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle: nil otherButtonTitles: @"OK",nil];
    [alert show];
}


-(void)processData:(NSArray *)response
{
    if([response count])
    {
        NSDictionary * aboutContents = [response objectAtIndex:0];
        self.title = [NSString stringWithFormat:@"%@", [aboutContents objectForKey:@"title"]];
        self.textView.text = [NSString stringWithFormat:@"%@", [aboutContents objectForKey:@"content"]];
        [self.textView sizeToFit];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.textView.frame.size.height + 20)];
    }
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
