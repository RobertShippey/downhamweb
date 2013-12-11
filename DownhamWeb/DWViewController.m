//
//  DWViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 02/09/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWViewController.h"

@interface DWViewController ()

@end

@implementation DWViewController

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //
    } else {
        UIImage *img = nil;
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect rect = CGRectMake(0, 0, width , 44);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       [DWColour purple].CGColor);
        CGContextFillRect(context, rect);
        
        img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
            //iOS 5 new UINavigationBar custom background
            [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics: UIBarMetricsDefault];
        } else {
            [self.navigationController.navigationBar insertSubview:[[UIImageView alloc] initWithImage:img] atIndex:0];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
