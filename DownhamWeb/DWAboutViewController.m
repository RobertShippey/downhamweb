//
//  DWAboutViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 21/11/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWAboutViewController.h"

@interface DWAboutViewController ()

@end

@implementation DWAboutViewController

@synthesize aboutText;

static NSString *aboutString = @"The downhamweb iPhone application was created by Robert Shippey (http://robertshippey.net/) in collaboration with Lingo Design (http://www.lingodesign.co.uk) for downhamweb (http://www.downhamweb.co.uk).\nInformation is accurate at the time it was published, and attempts will be made in good faith to keep it up-to-date.\nTo submit feedback, or report something broken in the app please visit support at http://robertshippey.net/projects/downhamweb-app/#support";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [aboutText setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [aboutText setText:aboutString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
