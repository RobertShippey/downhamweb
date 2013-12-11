//
//  DWCalendarViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 21/05/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kGoogleCalendarURL [NSURL URLWithString:  @"http://www.google.com/calendar/feeds/downhamweb@googlemail.com/public/full?alt=json&orderby=starttime&max-results=50&singleevents=true&sortorder=ascending&futureevents=true"]
#import <Foundation/NSJSONSerialization.h>
#import <UIKit/UIKit.h>
#import "GoogCal.h"
#import <EventKit/EventKit.h>

@interface DWCalendarViewController : DWTableViewController <UITableViewDelegate, UITableViewDataSource>

@end

@interface DWCalendarTimeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIView *seperator;

@end