//
//  DWBusinessCategoryViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 07/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWBusinessCategoryViewController.h"
#import "DWBusinessPoint.h"


@interface DWBusinessCategoryViewController ()

@end

@implementation DWBusinessCategoryViewController {
    NSArray *keys;
    NSArray *values;
    
    NSString *selectedCategory;
    DWBusinessMapViewController *map;
}

- (void) setMapView:(DWBusinessMapViewController *) theMap {
    map = theMap;
}

- (BOOL) dataIsSet {
    if (keys) {
        return true;
    } else return false;
}

- (void) workOutCategories:(NSArray *)pins {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    // Start TIMER
    NSDate *timeBefore = [NSDate new];
    // ...
    
    for (DWBusinessPoint *p in pins) {
        if (!p.subtitle || [p.subtitle isEqualToString:@""]) {
            NSLog(@"Business has no subtitle: %@", p.title);
            continue;
        }
        NSUInteger count = [[dict objectForKey:p.subtitle] unsignedIntegerValue];
        if (count) {
            count++;
        } else {
            count = 1;
        }
        [dict setObject:[NSNumber numberWithUnsignedInteger:count]  forKey:p.subtitle];
    }
    
    NSMutableArray *unorderedKeys = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
    NSMutableArray *unorderedValues = [[NSMutableArray alloc] initWithArray:[dict allValues]];
    
    
    // Bubble sort
    int count = [unorderedKeys count];
    for (int i=0; i<count; i++)
    {
        for (int j=count-1; j>0; j--)
        {
            NSString *firstString = [unorderedKeys objectAtIndex:j-1];
            NSString *secondString = [unorderedKeys objectAtIndex:j];
            
            unichar fc = [firstString characterAtIndex:0];
            unichar sc = [secondString characterAtIndex:0];
            
            if (sc < fc) {
                [unorderedKeys setObject:firstString atIndexedSubscript:j];
                [unorderedKeys setObject:secondString atIndexedSubscript:j-1];
                
                NSNumber *a = [unorderedValues objectAtIndex:j-1];
                NSNumber *b = [unorderedValues objectAtIndex:j];
                [unorderedValues setObject:a atIndexedSubscript:j];
                [unorderedValues setObject:b atIndexedSubscript:j-1];
            }
        }
    }
    
    keys = unorderedKeys;
    values = unorderedValues;
    
    
    // ...
    double timePassed_ms = [timeBefore timeIntervalSinceNow] * -1000.0;
    NSLog(@"WORKING CATS: %fms", timePassed_ms);
    // End TIMER

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *title = [NSString stringWithFormat:@"%@: %d", [keys objectAtIndex:indexPath.row], [[values objectAtIndex:indexPath.row] intValue]];
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedCategory = [keys objectAtIndex:indexPath.row];
    [self backToMap];
    
}

- (IBAction)showAll:(id)sender {
    selectedCategory = kNoCategorySelected;
    [self backToMap];
}

- (void) backToMap {
    [map setCategory:selectedCategory];
    [map setShouldZoom:YES];
    map = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSString *MPCatValue = [selectedCategory isEqualToString:@""] ? @"All" : selectedCategory;
    [[Mixpanel sharedInstance] track:@"BusinessCategoryVC Selected"
                          properties:@{@"business_category": MPCatValue}];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
