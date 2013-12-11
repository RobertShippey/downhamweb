//
//  DWEventDetailsViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 21/05/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWEventDetailsViewController.h"
#import <EventKit/EventKit.h>
#include <time.h>


@interface DWEventDetailsViewController ()

@end

@implementation DWEventDetailsViewController

@synthesize eventTitle, time, description, eventDetails;
@synthesize line, notify;



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
    
    notify.titleLabel.textColor = [DWColour purple];
   line.backgroundColor = [DWColour purple];
    
    eventTitle.text = eventDetails.Title;
    
    if ([eventDetails.Where isEqualToString:@""]) {
        description.text = eventDetails.Description;
    } else {
        description.text = [NSString stringWithFormat:@"Location: %@.\n\n%@", eventDetails.Where, eventDetails.Description];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormat setLocale:locale];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *startDateStr = [dateFormat stringFromDate:eventDetails.StartDate];
    
    [dateFormat setDateFormat:@"h:mm a"];
    
    if ([eventDetails isAllDay]) {
        if ([eventDetails isMultiDay]) {
            NSDateFormatter *days = [NSDateFormatter new];
            [days setDateStyle:NSDateFormatterMediumStyle];
            [days setLocale:[NSLocale currentLocale]];
            NSString *formattedDays = [NSString stringWithFormat:@"All day from %@ to %@", [days stringFromDate:eventDetails.StartDate], [days stringFromDate:eventDetails.EndDate]];
            time.text = formattedDays;
        } else {
            time.text = [NSString stringWithFormat:@"All day on %@", startDateStr];
        }
    } else {
        NSString *hoursOpen = [NSString stringWithFormat:@"%@ to %@", [dateFormat stringFromDate:eventDetails.StartDate], [dateFormat stringFromDate:eventDetails.EndDate]];
        time.text = [NSString stringWithFormat:@"%@ on %@", hoursOpen, startDateStr];
    }
    
    [time setTextAlignment:NSTextAlignmentCenter];
    [eventTitle setTextAlignment:NSTextAlignmentCenter];
    
    [TestFlight passCheckpoint:@"EventDetailsVC"];
    [[Mixpanel sharedInstance] track:@"EventDetailVC Did Appear"];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [eventTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [time setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [description setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [notify.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [TestFlight passCheckpoint:@"EventDetailsVC Did Appear"];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)addToCalButton:(id)sender
{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // iOS 6 and later
        // This line asks user's permission to access his calendar
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if (error) {
                 TFLog(@"Some error with saving to calendar: %@", [error description]);
                 return;
             }
             
             if (granted) // user user is ok with it
             {
                 EKEventStore *eventStore = [[EKEventStore alloc] init];
                 
                 EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                 event.title     = eventDetails.Title;
                 
                 event.startDate = eventDetails.StartDate;
                 event.endDate   = eventDetails.EndDate;
                 NSString *notes = [NSString stringWithFormat:@"%@\nEvent from downhamweb's Events Diary http://www.downhamweb.co.uk/events-diary/", eventDetails.Description];
                 [event setNotes:notes];
                 //event.description = calEvent.description;
                 
                 [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                 NSError *err;
                 [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSString *message = [NSString stringWithFormat:@"%@ was saved to your default calendar", eventDetails.Title];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event saved" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                     [[Mixpanel sharedInstance] track:@"eventSavedToCal" properties:@{@"eventTitle":event.title}];
                     
                     [alert show];
                 });
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSString *message = [NSString stringWithFormat:@"%@ was saved not to your default calendar. You may need to change your calendar privacy settings.", eventDetails.Title];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event not saved" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                     [alert show];
                 });
             }
         }];
    }
    
    // iOS < 6
    else
    {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = eventDetails.Title;
        
        event.startDate = eventDetails.StartDate;
        event.endDate   = eventDetails.EndDate;
        NSString *notes = [NSString stringWithFormat:@"%@\nEvent from downhamweb's Events Diary http://www.downhamweb.co.uk/events-diary/", eventDetails.Description];
        [event setNotes:notes];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        NSString *message = [NSString stringWithFormat:@"%@ was saved to your default calendar", eventDetails.Title];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event saved" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [[Mixpanel sharedInstance] track:@"eventSavedToCal" properties:@{@"eventTitle":event.title}];
        [alert show];
        
    }
    
}

- (IBAction)scheduleEvent:(id)sender
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    // Get the current date
    NSDate *pickerDate = self.eventDetails.StartDate;
    
    if ([pickerDate compare:[NSDate date]] == NSOrderedAscending) {
        UIAlertView *old =[[UIAlertView alloc] initWithTitle:@"Event already started" message:@"This event has already begun, no reminder has been set." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [old show];
        return;
    }
    
    // Break the date up into components
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
												   fromDate:pickerDate];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
												   fromDate:pickerDate];
    // Set up the fire time
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[timeComponents hour]-1];
	// Notification will fire one hour before event
    [dateComps setMinute:[timeComponents minute]];
	[dateComps setSecond:[timeComponents second]];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
	// Notification details
    localNotif.alertBody = [NSString stringWithFormat:@"%@ will start in 1 hour.", eventDetails.Title];
	// Set the action button
    localNotif.alertAction = @"View";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    
	// Specify custom data for the notification
    localNotif.userInfo = [self saveToDictionary];
    
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setLocale:[NSLocale currentLocale]];
    [timeFormat setDateFormat:@"h:mm a"];
    NSString *timeOfDay = [timeFormat stringFromDate:itemDate];
    
    NSString *message = [NSString stringWithFormat:@"You will be reminded about %@ at %@", eventDetails.Title, timeOfDay];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification scheduled" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [[Mixpanel sharedInstance] track:@"eventNotificationScheduled" properties:@{@"eventTitle":eventDetails.Title}];
    [alert show];
}

- (void) loadFromDictionary: (NSDictionary *) dict
{
    eventTitle.text = [dict objectForKey:@"eventTitle"];
    time.text = [dict objectForKey:@"time"];
    description.text = [dict objectForKey:@"desc"];
}

- (NSDictionary *) saveToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:eventTitle.text forKey:@"eventTitle"];
    [dict setObject:time.text forKey:@"time"];
    [dict setObject:description.text forKey:@"desc"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
