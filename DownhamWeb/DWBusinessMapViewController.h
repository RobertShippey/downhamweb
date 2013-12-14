//
//  DWBusinessMapViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 23/11/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWViewController.h"
#import <MapKit/MapKit.h>

#define kNoCategorySelected @"DWNoBusinessCategorySelected"

@interface DWBusinessMapViewController : DWViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void) setCategory:(NSString *) cat;
- (void) setShouldZoom:(BOOL) should;

@end
