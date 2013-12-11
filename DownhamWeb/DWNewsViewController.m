//
//  DWNewsViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 20/05/2013.
//

#import "DWNewsViewController.h"
#import "SMXMLDocument.h"
#import "UIImageView+WebCache.h"
#import "DWWebNewsViewController.h"


@implementation DWNewsTableCell

@synthesize articleImage, articleTitle, articleSubtitle;

@end



@interface DWNewsViewController ()

@end

@implementation DWNewsViewController {
    NSMutableArray *tableData;
    NSDateFormatter *tableDateFormatter;
    NSDate *lastUpdated;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    //[refresh setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to refresh"]];
    self.refreshControl = refresh;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    tableDateFormatter = [[NSDateFormatter alloc] init];
    [tableDateFormatter setLocale:[NSLocale currentLocale]];
    [tableDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [tableDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [tableDateFormatter setDoesRelativeDateFormatting:YES];
    
    tableData = [[NSUserDefaults standardUserDefaults] objectForKey:@"dw-rss-tabledata"];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (lastUpdated) {
        if (abs([lastUpdated timeIntervalSinceNow]) > 2*60*60 ) { //60seconds * 60minutes = 1hour
            [self startLoading];
            NSLog(@"news updated!");
        }
    } else {
        [self startLoading];
        NSLog(@"retrying after failure");
    }
    
    [TestFlight passCheckpoint:@"NewsVC Did Appear"];
    [[Mixpanel sharedInstance] track:@"NewsVC Did Appear"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableData) {
        return [tableData count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Article";
    
    DWNewsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *post = [tableData objectAtIndex:indexPath.row];
    
    cell.articleTitle.text = [post objectForKey:@"title"];
    
    NSDate *date = [post objectForKey:@"date"];
    
    cell.articleSubtitle.text = [tableDateFormatter stringFromDate:date];
    
    [cell.articleImage setImageWithURL:[NSURL URLWithString:[post objectForKey:@"picture"]]
                    placeholderImage:[UIImage imageNamed:@"dw114.png"]];
    
    [cell.articleTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [cell.articleSubtitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    
    return cell;
}



#pragma mark - Table view delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSDictionary *dict = [tableData objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    
    NSString *urlString = [dict objectForKey:@"url"];
    
    if (urlString)
    {
        
        NSURL *url = [NSURL URLWithString:urlString];
        [(DWWebNewsViewController *)segue.destinationViewController loadURL:url];
        
    }
}

-(void) dismissNews
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) downloadData {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //get a dispatch queue
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.downhamweb.co.uk/category/news/feed/"]];
        
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
            return;
        }
        
        NSMutableArray *tempTableData = [NSMutableArray new];
        
        NSError *err;
        SMXMLDocument *xmlDoc = [SMXMLDocument documentWithData:data error:&err];
        
        if(!err){
            
            NSDateFormatter *rssDateFormatter = [NSDateFormatter new];
            [rssDateFormatter setDateFormat:@"dd MMM yyyy"];
            
            SMXMLElement *feed = [xmlDoc.root childNamed:@"channel"];
            
            for(SMXMLElement *entry in [feed childrenNamed:@"item"]){
                
                NSMutableDictionary *entryDict = [NSMutableDictionary new];
                
                [entryDict setValue:[[entry childNamed:@"title"] value] forKey:@"title"];
                
                [entryDict setValue:[entry valueWithPath:@"link"] forKey:@"url"];
                
                NSString *dateString = [entry valueWithPath:@"pubDate"];
                
                dateString = [dateString substringWithRange:NSRangeFromString(@"5 11")];
                
                NSDate *date = [rssDateFormatter dateFromString: dateString];
                
                [entryDict setValue:date forKey:@"date"];
                
                
                NSString *desc = [[entry childNamed:@"description"] value];
                NSError *err;
                SMXMLDocument *descDoc = [SMXMLDocument documentWithData:[desc dataUsingEncoding:NSUTF8StringEncoding] error:&err];
                SMXMLElement *img = [[descDoc.root childrenNamed:@"img"] objectAtIndex:0];
                
                NSString *imgurl = [img attributeNamed:@"src"];
                
                [entryDict setValue:imgurl forKey:@"picture"];
                
                [tempTableData addObject:entryDict];
                
            }
            
            lastUpdated = [NSDate date];
            tableData = tempTableData;
            [[NSUserDefaults standardUserDefaults] setObject:tableData forKey:@"dw-rss-tabledata"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            //[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to refresh"]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
    });
    
}

-(void) refresh
{
    //[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Loading..."]];
    [self downloadData];
}

-(void) startLoading
{
    [self.refreshControl beginRefreshing];
    
    if (self.tableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        } completion:nil];
        
    }
    
    [self refresh];
}

@end
