//
//  DWWebNewsViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 25/06/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWWebNewsViewController.h"
#import "ARChromeActivity.h"
#import "TUSafariActivity.h"

@interface DWWebNewsViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;

@end

@implementation DWWebNewsViewController {
    NSString *pageTitle;
}

@synthesize webView, loadingActivity, shareButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_urlToLoad];
    [webView loadRequest:requestObj];
    [loadingActivity startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [shareButton setEnabled:NO];
    
    if (!NSClassFromString (@"UIActivityViewController")) {
        NSMutableArray *items = [self.navigationItem.rightBarButtonItems mutableCopy];
        [items removeObject:shareButton];
        [self.navigationItem setRightBarButtonItems:items animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Mixpanel sharedInstance] track:@"News Web View"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [webView stopLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadURL:(NSURL *)url
{
    NSString *fullURL = [NSString stringWithFormat:@"%@#content", [url absoluteString]];
    _urlToLoad = [NSURL URLWithString:fullURL];
    
}

-(IBAction)share:(id)sender
{
    NSURL *shortURL = [NSURL URLWithString:[webView stringByEvaluatingJavaScriptFromString:@"var links = document.head.getElementsByTagName('link'); for(var link in links){ if(links.hasOwnProperty(link)){ var l = links[link]; if(l.rel === 'shortlink'){ l.href.toString(); } } }"]];
    if (!shortURL) {
        shortURL = _urlToLoad;
    }
    
    NSArray *activityItems = @[[NSString stringWithFormat:@"Check out this post on downhamweb: %@", pageTitle], shortURL];
    NSArray *activities = @[[ARChromeActivity new], [TUSafariActivity new]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    [activityController setTitle:pageTitle];
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed){
        if (completed) {
            [[Mixpanel sharedInstance] track:@"newsShared" properties:@{@"newsSharedActivityType":activityType, @"newsURL":_urlToLoad}];
        }
    }];
    [self presentViewController:activityController animated:YES completion:nil];

}

- (void)webViewDidFinishLoad:(UIWebView *)view {
    pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    pageTitle = [pageTitle stringByReplacingOccurrencesOfString:@" - downhamweb" withString:@""];
    [self.navigationItem setTitle:pageTitle];
    [loadingActivity stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [shareButton setEnabled:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Show error alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not load page", nil)
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}

@end
