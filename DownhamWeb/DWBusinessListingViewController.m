//
//  DWBusinessListingViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 03/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWBusinessListingViewController.h"
#import <AddressBook/ABPerson.h>

@interface DWBusinessListingViewController ()

@end

@implementation DWBusinessListingViewController {
    DWBusinessPoint *business;
}

@synthesize callBtn, emailBtn, descriptionTextView, addressTextView, descriptionLbl, addressLbl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = business.title;
    
    [descriptionLbl setBackgroundColor:[DWColour purple]];
    [descriptionLbl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [descriptionLbl setTextColor:[DWColour white]];
    
    [descriptionTextView setTintColor:[DWColour purple]];
    [descriptionTextView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [descriptionTextView setText:business.businessDescription];
    
    [addressTextView setTintColor:[DWColour purple]];
    [addressTextView setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [addressTextView setText:business.address];
    
    [addressLbl setBackgroundColor:[DWColour purple]];
    [addressLbl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [addressLbl setTextColor:[DWColour white]];
    
    [callBtn setTitle:[business phoneNumber] forState:UIControlStateNormal];
    [[callBtn titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [callBtn setTintColor:[DWColour purple]];
    
    [emailBtn setTitle:[business emailAddress] forState:UIControlStateNormal];
    [[emailBtn titleLabel] setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [emailBtn setTintColor:[DWColour purple]];
    
}
    
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Mixpanel sharedInstance] track:@"BusinessListingVC DidAppear" properties:@{@"business_title": business.title}];
}

- (void) setBusiness:(DWBusinessPoint *)data {
    business = data;
}

- (IBAction)callBusiness:(id)sender {
    NSString *callString = [NSString stringWithFormat:@"telprompt:%@", [business.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSURL *callURL = [NSURL URLWithString:callString];
    
    BOOL canCall = [[UIApplication sharedApplication] canOpenURL:callURL];
    if (canCall) {
        [[UIApplication sharedApplication] openURL:callURL];
    } else {
        UIAlertView *cantCall = [[UIAlertView alloc] initWithTitle:@"Could not call"
                                                           message:@"Could not call a phone number on this device"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Okay"
                                                 otherButtonTitles:nil, nil];
        [cantCall show];
    }
}

- (IBAction)emailBusiness:(id)sender {
    NSString *callString = [NSString stringWithFormat:@"mailto:%@", business.emailAddress];
    NSURL *callURL = [NSURL URLWithString:callString];
    
    BOOL canCall = [[UIApplication sharedApplication] canOpenURL:callURL];
    if (canCall) {
        [[UIApplication sharedApplication] openURL:callURL];
    } else {
        UIAlertView *cantCall = [[UIAlertView alloc] initWithTitle:@"Could not call"
                                                           message:@"Could not call a phone number on this device"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Okay"
                                                 otherButtonTitles:nil, nil];
        [cantCall show];
    }
}

- (IBAction)driveToBusiness:(id)sender {
    
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:business.coordinate addressDictionary:@{(NSString *)kABPersonAddressStreetKey : business.address,
        (NSString *)kABPersonAddressCountryKey : @"UK"}];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:place];
    [mapItem setName:business.title];
    [mapItem setPhoneNumber:business.phoneNumber];
    
    [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    
}

@end
