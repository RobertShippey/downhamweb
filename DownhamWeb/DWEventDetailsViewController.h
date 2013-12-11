//
//  DWEventDetailsViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 21/05/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogCal.h"

@interface DWEventDetailsViewController : DWViewController

@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UITextView *description;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (nonatomic, retain) IBOutlet UIButton *notify;

@property (nonatomic, retain) GoogCal *eventDetails;

- (void) loadFromDictionary: (NSDictionary *) dict;

-(IBAction)addToCalButton:(id)sender;
- (IBAction)scheduleEvent:(id)sender;

@end
