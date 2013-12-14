//
//  DWBusinessMapViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 23/11/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWBusinessMapViewController.h"
#import "DWBusinessPoint.h"
#import "DWBusinessListingViewController.h"
#import "DWBusinessCategoryViewController.h"

@interface DWBusinessMapViewController ()
    
    @end

@implementation DWBusinessMapViewController {
    NSArray *allPins;
    NSString *categoryFilter;
    BOOL shouldZoom;
}
    
    @synthesize mapView;
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    categoryFilter = @"";
    [self loadPlaces];
    [self zoomToFitMapAnnotations];
    shouldZoom = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Mixpanel sharedInstance] track:@"BusinessMapVC Did Appear"];
    
    if (shouldZoom) {
        [self zoomToFitMapAnnotations];
        shouldZoom = NO;
    }
}

- (void) setShouldZoom:(BOOL)should {
    shouldZoom = should;
}

- (void) setCategory:(NSString *)cat {
    categoryFilter = cat;
    
    [mapView removeAnnotations:allPins];
    [mapView addAnnotations:allPins];
    
    if ([categoryFilter isEqualToString:kNoCategorySelected]) {
        return;
    }
    
    for (DWBusinessPoint *p in mapView.annotations) {
        if (![p.subtitle isEqualToString:categoryFilter]) {
            [mapView removeAnnotation:p];
        }
    }
}

- (void) loadPlaces {
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"Businesses" ofType:@"plist"];
    
    NSMutableArray *businessList = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    for (NSDictionary *dict in businessList) {
        
        DWBusinessPoint *point = [[DWBusinessPoint alloc] initWithDictionary:dict];
        [mapView addAnnotation:point];
        
    }
    allPins = mapView.annotations;
}

-(void)zoomToFitMapAnnotations
    {
        if([mapView.annotations count] == 0)
        return;
        
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        for(MKPointAnnotation *annotation in mapView.annotations)
        {
//            if([annotation isKindOfClass:[MKUserLocation class]]){
//                continue;
//            }
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
        }
        
        MKCoordinateRegion region;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4; // Add a little extra space on the sides
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4; // Add a little extra space on the sides
        
        //region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
    }
    
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if([annotation isKindOfClass: [MKUserLocation class]]) { return nil;}
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [rightButton setTintColor:[DWColour purple]];
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    
    pinView.pinColor = MKPinAnnotationColorRed;
    
    return pinView;
}
    
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
    {
        [self performSegueWithIdentifier:@"mapToBusinessSegue" sender:self];
    }
    
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"mapToBusinessSegue"]){
        
        DWBusinessPoint *pin = [mapView.selectedAnnotations firstObject];
        DWBusinessListingViewController *vc = segue.destinationViewController;
        vc.business = pin;
    }
    else if ([segue.identifier isEqualToString:@"mapCategories"]) {
        
        DWBusinessCategoryViewController *cats = segue.destinationViewController;
        [cats setMapView:self];
        if (![cats dataIsSet]) {
            [cats workOutCategories:allPins];
        }
        
    }
    [super prepareForSegue:segue sender:sender];
}
    
    @end
