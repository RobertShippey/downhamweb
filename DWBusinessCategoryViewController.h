//
//  DWBusinessCategoryViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 07/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWBusinessMapViewController.h"

@interface DWBusinessCategoryViewController : DWTableViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)showAll:(id)sender;

- (BOOL) dataIsSet;
- (void) workOutCategories:(NSArray *)pins;
- (void) setMapView:(DWBusinessMapViewController *)theMap;

@end
