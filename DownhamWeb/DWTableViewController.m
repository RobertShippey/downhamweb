//
//  DWTableViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 02/09/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWTableViewController.h"

@interface DWTableViewController ()

@end

@implementation DWTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [self.tableView setBackgroundView: background];
    }
}

@end
