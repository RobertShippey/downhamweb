//
//  DWCalendarViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 21/05/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWCalendarViewController.h"
#import "ISO8601DateFormatter.h"
#import "DWEventDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "SMXMLDocument.h"

#define kEventDataKey @"dw-gcal-events"

@implementation DWCalendarViewController {
    NSDateFormatter *dateFormat;
    NSDateFormatter *timeFormat;
    NSMutableArray *eventData;
    NSInteger selectedRow;
    NSDate *lastUpdated;
    NSDate *lastUpdatedWeather;
    
    NSMutableArray *weatherImages;
    NSMutableArray *weatherTemps;
    
    Class thereIsUIRefreshControl;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData *archivedEventData = [[NSUserDefaults standardUserDefaults] objectForKey:kEventDataKey];
    eventData = [NSKeyedUnarchiver unarchiveObjectWithData: archivedEventData];
    
    thereIsUIRefreshControl = NSClassFromString(@"UIRefreshControl");
    if (thereIsUIRefreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    
    NSLocale *locale = [NSLocale currentLocale];
    
    //self.tableView.rowHeight = 55;
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:locale];
    //[dateFormat setDateFormat:@"M/dd/yyyy"];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    [dateFormat setDoesRelativeDateFormatting:YES];
    
    timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setLocale:locale];
    //[timeFormat setDateStyle:NSDateFormatterMediumStyle];
    [timeFormat setDateFormat:@"h:mm a"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (lastUpdated) {
        if (abs([lastUpdated timeIntervalSinceNow]) > 60*60 ) { //60seconds * 60minutes = 1hour
            [self startLoading];
            [self loadWeather];
            NSLog(@"events updated!");
        }
    } else {
        [self startLoading];
        [self loadWeather];
        NSLog(@"retrying after failure (or first load)");
    }
    
    [TestFlight passCheckpoint:@"CalendarVC Did Appear"];
    [[Mixpanel sharedInstance] track:@"CalendarVC Did Appear"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    if (eventData) {
        return [eventData count];
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (eventData) {
        NSDictionary *data = [eventData objectAtIndex:section];
        NSArray *arr = [data objectForKey:@"array"];
        return [arr count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 0)];
//    [footer setBackgroundColor:[UIColor orangeColor]];
//    return footer;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    
    UILabel *weatherLbl = [[UILabel alloc] initWithFrame:CGRectMake(220, 5 , 50, 20)];
    [weatherLbl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    weatherLbl.backgroundColor = [DWColour clear];
    weatherLbl.textColor = [DWColour white];
    
    UIImageView *weatherImg = [[UIImageView alloc] initWithFrame:CGRectMake(270, 0, 30, 30)];
    weatherImg.backgroundColor = [DWColour clear];
    
    if ([[[eventData objectAtIndex:0] objectForKey:@"date"] isEqualToString:@"Today"]) {
        if (section < [weatherTemps count]) {
            NSString *temp = [weatherTemps objectAtIndex:section];
            if (temp) {
                NSURL *imageURL = [weatherImages objectAtIndex:section];
                [weatherImg setImageWithURL:imageURL];
                weatherLbl.text = [NSString stringWithFormat:@"%@ºC", temp];
            }
        }
    } else if ([[[eventData objectAtIndex:0] objectForKey:@"date"] isEqualToString:@"Tomorrow"]) {
        int tomorrowSection = section+1;
        if (tomorrowSection < [weatherTemps count]) {
            NSString *temp = [weatherTemps objectAtIndex:tomorrowSection];
            if (temp) {
                NSURL *imageURL = [weatherImages objectAtIndex:tomorrowSection];
                [weatherImg setImageWithURL:imageURL];
                weatherLbl.text = [NSString stringWithFormat:@"%@ºC", temp];
            }
        }
    }
    
    
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] init];
    //view.backgroundColor = [UIColor greenColor];
    
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 340, 30)];
    innerView.backgroundColor = [DWColour purple];
    
    [view addSubview:innerView];
    
    // Create label with section title
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    [titleLbl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    
    [innerView addSubview:titleLbl];
    [innerView addSubview:weatherLbl];
    [innerView addSubview:weatherImg];
    
    //If you add a bit to x and decrease y, it will be more in line with the tableView cell (that is in iPad and landscape)
    titleLbl.backgroundColor = [DWColour clear];
    titleLbl.textColor = [DWColour white];
    //titleLbl.shadowColor = [UIColor whiteColor];
    //titleLbl.shadowOffset = CGSizeMake(0, -1);
    titleLbl.text = sectionTitle;
    
    return view;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (eventData) {
        NSDictionary *data = [eventData objectAtIndex:section];
        return [data objectForKey:@"date"];
    } else {
        return @" ";
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *d = [eventData objectAtIndex:[indexPath section]];
    NSArray *a = [d objectForKey:@"array"];
    GoogCal *eventLcl = (GoogCal *) [a objectAtIndex:[indexPath row]];
    
    if ([eventLcl isAllDay]) {
        
        static NSString *CellIdentifier = @"EventCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //[cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        
        // Configure the cell...
        
        cell.textLabel.text = eventLcl.Title;
        cell.detailTextLabel.text = eventLcl.Where;
        
        if ([eventLcl.Where isEqualToString:@""]) {
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            cell.textLabel.numberOfLines = 2;
        } else {
            [cell.textLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            cell.textLabel.numberOfLines = 1;
        }
        
//        if ([cell.textLabel respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)]) {
//            [cell.textLabel setAdjustsLetterSpacingToFitWidth:YES];
//        }
        
        [cell.textLabel setBackgroundColor:[DWColour clear]];
        [cell.detailTextLabel setBackgroundColor:[DWColour clear]];
        
        [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
        [cell.detailTextLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        
        
        return cell;
    } else {
        
        if ([eventLcl.Where isEqualToString:@""]) {
            
            static NSString *CellIdentifier = @"EventTimeCellNoLoc";
            
            DWCalendarTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            //[cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
            
            // Configure the cell...
            
            cell.title.text = eventLcl.Title;
            
            cell.time.textAlignment = NSTextAlignmentRight;
            cell.time.text = [timeFormat stringFromDate:eventLcl.StartDate];
            
//            if ([cell.title respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)]) {
//                [cell.title setAdjustsLetterSpacingToFitWidth:YES];
//            }
            
            [cell.title setBackgroundColor:[DWColour clear]];
            
            [cell.title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
            [cell.location setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
            [cell.time setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            
            return cell;
            
        } else {
            
            static NSString *CellIdentifier = @"EventTimeCell";
            
            DWCalendarTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            //[cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
            
            // Configure the cell...
            
            cell.title.text = eventLcl.Title;
            cell.location.text = eventLcl.Where;
            
            cell.time.textAlignment = NSTextAlignmentRight;
            cell.time.text = [timeFormat stringFromDate:eventLcl.StartDate];
            
//            if ([cell.title respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)]) {
//                [cell.title setAdjustsLetterSpacingToFitWidth:YES];
//            }
            
            [cell.title setBackgroundColor:[DWColour clear]];
            [cell.location setBackgroundColor:[DWColour clear]];
            
            [cell.title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
            [cell.location setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
            [cell.time setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
            
            return cell;
        }
    }
}

-(void)LoadCalendarData
{
    lastUpdated = [NSDate date];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        // This is really slow :(
        NSDate *timeBefore = [NSDate new];
        NSData *responseData = [NSData dataWithContentsOfURL: kGoogleCalendarURL];
        double timePassed_ms = [timeBefore timeIntervalSinceNow] * -1000.0;
        NSLog(@"time for 50 events: %fms", timePassed_ms);
        
        
        //parse out the json data
        NSError* error;
        NSDictionary* json;
        
        if (responseData) {
            json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                   options:kNilOptions
                                                     error:&error];
            
            if (!error) {
                lastUpdated = [NSDate date];                
                eventData = [NSMutableArray new];
                
                ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
                
                // Set up data structure
                int sectionIndex = 0;
                int isFirst = 1;
                
                //prepare for date checks
                NSDate *now = [NSDate date];
                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
                NSDate *midnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:now]];
                
                eventData = [[NSMutableArray alloc]init];
                
                NSDictionary* latestLoans = [json objectForKey:@"feed"]; //2d
                NSArray* arrEvent = [latestLoans objectForKey:@"entry"];
                for (NSDictionary *event in arrEvent)
                {
                    GoogCal *googCalObj = [[GoogCal alloc]init];
                    
                    NSDictionary *title = [event objectForKey:@"title"];
                    googCalObj.Title = [title objectForKey:@"$t"];
                    
                    //dates are stored in an array
                    NSArray *dateArr = [event objectForKey:@"gd$when"];
                    for(NSDictionary *dateDict in dateArr)
                    {
                        
                        NSDate *endDate = [formatter dateFromString:[dateDict objectForKey:@"endTime"]];
                        NSDate *startDate = [formatter dateFromString:[dateDict objectForKey:@"startTime"]];
                        
                        googCalObj.EndDate = endDate; //[endDate addTimeInterval:-3600*6];
                        googCalObj.StartDate = startDate; //[startDate addTimeInterval:-3600*6];
                        
                        break;
                    }
                    
                    if (([googCalObj.StartDate timeIntervalSinceDate:midnight] < 0) || ([googCalObj.EndDate timeIntervalSinceDate:midnight] < 0)) {
                        //ignore the event if it started or finished earlier than today
                        continue;
                    }
                    
                    NSArray *whereArray = [event objectForKey:@"gd$where"];
                    for (NSDictionary *whereDict in whereArray) {
                        googCalObj.Where = [whereDict objectForKey:@"valueString"];
                        break;
                    }
                    
                    
                    NSDictionary *content = [event objectForKey:@"content"];
                    googCalObj.Description = [content objectForKey:@"$t"];
                    
                    
                    NSString *sectionDate = [dateFormat stringFromDate:googCalObj.StartDate];
                    
                    if (isFirst) {
                        NSMutableDictionary *first = [NSMutableDictionary new];
                        [first setValue:[NSMutableArray new] forKey:@"array"];
                        [first setValue:sectionDate forKey:@"date"];
                        [eventData addObject:first];
                        isFirst = 0;
                    }
                    
                    // if part of the previous section
                    if ([sectionDate isEqualToString:[[eventData objectAtIndex:sectionIndex] objectForKey:@"date" ]]) {
                        [[[eventData objectAtIndex:sectionIndex] objectForKey:@"array"] addObject:googCalObj];
                    } else {
                        // otherwise move up one and start a new section
                        sectionIndex++;
                        NSMutableDictionary *newDict = [NSMutableDictionary new];
                        NSMutableArray *newArray = [NSMutableArray new];
                        [newArray addObject:googCalObj];
                        [newDict setValue:newArray forKey:@"array"];
                        [newDict setValue:sectionDate forKey:@"date"];
                        [eventData addObject:newDict];
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    
                }
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if (thereIsUIRefreshControl) {
                [self.refreshControl endRefreshing];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        
        NSData *encodedEventData = [NSKeyedArchiver archivedDataWithRootObject:eventData];
        [[NSUserDefaults standardUserDefaults] setObject:encodedEventData forKey:kEventDataKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    });
    
}

- (void) refresh
{
    [self LoadCalendarData];
    [self loadWeather];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // if ([segue.identifier isEqualToString:@"eventSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DWEventDetailsViewController *destViewController = segue.destinationViewController;
    
    NSDictionary *d = [eventData objectAtIndex:indexPath.section];
    NSArray *a = [d objectForKey:@"array"];
    destViewController.eventDetails = [a objectAtIndex:indexPath.row];
    //}
}

- (void) startLoading
{
    if (thereIsUIRefreshControl) {
        [self.refreshControl beginRefreshing];
        
        if (self.tableView.contentOffset.y == 0) {
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            } completion:nil];
            
        }
    }
    
    [self refresh];
}

- (void) loadWeather {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (!(abs([lastUpdatedWeather timeIntervalSinceNow]) > 15*60) && lastUpdatedWeather) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }

    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v1/weather.ashx?q=PE38&format=xml&num_of_days=5&key=6gxp3k9r6p54d6nednhq5t3r"]];
        //Please don't steal me key :)
        
        NSError *err;
        
        SMXMLDocument *xmlDoc = [SMXMLDocument documentWithData:data error:&err];
        
        if(!err){
            
            weatherImages = [NSMutableArray new];
            weatherTemps = [NSMutableArray new];
            
            NSArray *weather = [xmlDoc.root childrenNamed:@"weather"];
            
            for (SMXMLElement *day in weather) {
                NSString * temp = (NSString *)[day valueWithPath:@"tempMaxC"];
                NSURL *iconURL = [NSURL URLWithString:[day valueWithPath:@"weatherIconUrl"]];
                if (iconURL && temp) {
                    [weatherTemps addObject:temp];
                    [weatherImages addObject:iconURL];
                } else {
                    weatherImages = nil;
                    weatherImages = nil;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    TFLog(@"Weather encountered some weird error and did not load");
                    return;
                }
            }
            
            lastUpdatedWeather = [NSDate date];
            
        } else {
            NSLog(@"Weather did not load: %@", [err debugDescription]);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    });
}

@end

@implementation DWCalendarTimeTableViewCell

@synthesize time, location, title, seperator;

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    [seperator setBackgroundColor:[DWColour purple]];
}
- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [seperator setBackgroundColor:[DWColour purple]];
    
}

@end
