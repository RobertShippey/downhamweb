//
//  DWBusinessListingViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 03/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWViewController.h"
#import "DWBusinessPoint.h"

@interface DWBusinessListingViewController : DWViewController

@property (strong, nonatomic) IBOutlet UIButton *callBtn;
@property (strong, nonatomic) IBOutlet UIButton *emailBtn;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextView *addressTextView;

@property (strong, nonatomic) IBOutlet UILabel *descriptionLbl;
@property (strong, nonatomic) IBOutlet UILabel *addressLbl;

- (void) setBusiness:(DWBusinessPoint *)business;

- (IBAction)callBusiness:(id)sender;
- (IBAction)emailBusiness:(id)sender;
- (IBAction)driveToBusiness:(id)sender;

@end
