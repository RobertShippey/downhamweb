//
//  DWWebNewsViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 25/06/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWWebNewsViewController : DWViewController

@property (nonatomic, retain) NSURL *urlToLoad;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

-(IBAction)share:(id)sender;
-(void)loadURL:(NSURL *)url;

@end
