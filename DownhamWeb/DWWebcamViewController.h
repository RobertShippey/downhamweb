//
//  DWWebcamViewController.h
//  DownhamWeb
//
//  Created by Robert Shippey on 20/05/2013.
//

#import <UIKit/UIKit.h>

@interface DWWebcamViewController : DWViewController

@property (nonatomic, retain) IBOutlet UIImageView *webcamImage;
@property (strong, nonatomic) IBOutlet UIView *flashingLight;
@property (strong, nonatomic) IBOutlet UILabel *onlineStatusLbl;

@property (strong, nonatomic) IBOutlet UIButton *aboutBtn;
@property (strong, nonatomic) IBOutlet UIImageView *advertImage;

@property (strong, nonatomic) IBOutlet UILabel *advertisingLbl;

- (IBAction)advertTapped:(id)sender;
- (IBAction)hideFullScreen;

@end