//
//  DWWebcamViewController.m
//  DownhamWeb
//
//  Created by Robert Shippey on 20/05/2013.
//

#import "DWWebcamViewController.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"
#import "SMXMLDocument.h"
//#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface DWWebcamViewController ()

@end

@implementation DWWebcamViewController {
    NSTimer *webcamTimer;
    id<SDWebImageOperation> op;
    BOOL landscape;
    UIImage *cache;
    UIImageOrientation pictureOr;
    BOOL webcamOnline;
    NSArray *adverts;
    NSTimer *advertTimer;
    int advertIndex;
    bool transparent;
    int failCount;
}

@synthesize webcamImage, advertisingLbl;

@synthesize aboutBtn, flashingLight, onlineStatusLbl, advertImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadAdvertPlist];
    
    aboutBtn.tintColor = [DWColour purple];
    flashingLight.backgroundColor = [DWColour orange];
    flashingLight.alpha = 0.75;
    transparent = NO;
    flashingLight.layer.cornerRadius = 10;
    onlineStatusLbl.text = @"Loading...";
    
    if (landscape) {
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        pictureOr = UIImageOrientationLeft;
        [self deviceOrientationDidChange];
        
        UIImage *image = [[UIImage alloc] initWithCGImage: cache.CGImage scale: 1.0 orientation: pictureOr];
        [webcamImage setImage:image];
        if (webcamOnline) {
            flashingLight.backgroundColor = [DWColour green];
        } else {
            flashingLight.backgroundColor = [DWColour errorRed];
        }
        
    } else {
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFullScreen)];
        [webcamImage addGestureRecognizer:tapper];
        [webcamImage setUserInteractionEnabled:YES];
    }
    
        UIImage *templogo = [UIImage imageNamed:@"site-logo.png"];
        UIImage * logo = [templogo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
        [logoView setTintColor:[DWColour purple]];
        
        self.navigationItem.titleView = logoView;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [TestFlight passCheckpoint:@"WebcamVC Did Appear"];
    [[Mixpanel sharedInstance] track:@"WebcamVC Did Appear"];
    
    [self performSelector:@selector(notifyAboutBandwidth) withObject:self afterDelay:2.0];
    
    [self updateWebcam:nil];
    [self updateAdvert];
    
    [self stopTimer];
    
    webcamTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateWebcam:) userInfo:nil repeats:YES];
    advertTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateAdvert) userInfo:nil repeats:YES];
    
    
    if (landscape) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopTimer];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (landscape) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [advertisingLbl setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWebcam:(NSTimer*)theTimer
{
    
    NSURL *url = [NSURL URLWithString:@"http://www.downhamweb.co.uk/wp/webcam-cache/"];
    
    // Debug url - straight from webcam
    //NSURL *url = [NSURL URLWithString:@"http://91.85.153.161/jpeg?id=1"];
    
    op = [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url
                                                             options:0
                                                            progress:nil
                                                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
          {
              if (image && finished)
              {
                  // Make a new bounding rectangle including our crop
                  CGRect newSize = CGRectMake(0.0, 20.0, image.size.width, (image.size.height-20.0));
                  
                  // Create a new image in quartz with our new bounds and original image
                  CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], newSize);
                  
                  // Pump our cropped image back into a UIImage object
                  UIImage *image = [UIImage imageWithCGImage:tmp];
                  
                  // Be good memory citizens and release the memory
                  CGImageRelease(tmp);
                  
                  if (landscape) {
                      
                      image = [[UIImage alloc] initWithCGImage: image.CGImage scale: 1.0 orientation: pictureOr];
                      
                  }
                  cache = image;
                  [webcamImage setImage:image];
                  webcamOnline = YES;
                                    [[[webcamImage gestureRecognizers] firstObject] setEnabled:YES];
                  failCount = 0;
              } else {
                  webcamOnline = NO;
                  [[[webcamImage gestureRecognizers] firstObject] setEnabled:NO];
                  failCount++;
                  if (failCount > 2) {
                      if (landscape) {
                          [self hideFullScreen];
                      } else {
                          [webcamImage setImage:[UIImage imageNamed:@"webcam-down.png"]];
                      }
                  }
                  
              }
              
              
              dispatch_async(dispatch_get_main_queue(), ^{
              if (webcamOnline) {
                  
                  if (transparent) {
                      [UIView animateWithDuration:2.5 animations:^{
                          flashingLight.backgroundColor = [DWColour green];
                          flashingLight.alpha = 0.75;}
                       ];
                  } else {
                      [UIView animateWithDuration:2.5 animations:^{
                          flashingLight.backgroundColor = [DWColour green];
                          flashingLight.alpha = 0.25;}
                       ];
                  }
                  
                  transparent = !transparent;
                  onlineStatusLbl.text = @"Online";
              } else {
                  [UIView animateWithDuration:1.0 animations:^{flashingLight.backgroundColor = [DWColour errorRed];}];
                  onlineStatusLbl.text = @"Offline";
              }
              });
              
          }];
}

- (void) updateAdvert {
    advertIndex++;
    if (advertIndex < [adverts count]) {
        
        NSDictionary *advert = [adverts objectAtIndex:advertIndex];
        NSURL *adImgUrl = [NSURL URLWithString:[advert objectForKey:@"Image"]];
        
        [advertImage setImageWithURL:adImgUrl];
        
        
    } else {
        advertIndex = -1;
        [self updateAdvert];
    }
    
}

- (IBAction)advertTapped:(id)sender {
    
    NSDictionary *advert = [adverts objectAtIndex:advertIndex];
    NSURL *website = [NSURL URLWithString:[advert objectForKey:@"Website"]];
    if ([[UIApplication sharedApplication] canOpenURL:website]) {
        [[UIApplication sharedApplication] openURL:website];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Tapped advert: %@", [advert objectForKey:@"Name"]]];
        [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Tapped advert: %@", [advert objectForKey:@"Name"]]];
    }
    
}

- (void) stopTimer
{
    if (webcamTimer) {
        [op cancel];
        [webcamTimer invalidate];
        webcamTimer = nil;
    }
    
    if (advertTimer) {
        [advertTimer invalidate];
        advertTimer = nil;
    }
    
}

-(void)setLandscape:(BOOL)isLandscape
{
    landscape = isLandscape;
}

-(void)setCache:(UIImage *)cacheImage
{
    cache = cacheImage;
}
-(void)setWebcamStatus:(BOOL) status {
    webcamOnline = status;
}

- (IBAction) hideFullScreen {
    [self stopTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"HIDE FULL SCREEN");
    
}

- (void) goToFullScreen {
    [self performSegueWithIdentifier:@"fullWebcam" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fullWebcam"]) {
        DWWebcamViewController *destViewController = segue.destinationViewController;
        [destViewController setLandscape:YES];
        [destViewController setCache:cache];
        [destViewController setWebcamStatus:webcamOnline];
        
        [TestFlight passCheckpoint:@"Webcam Full Screen"];
        [[Mixpanel sharedInstance] track:@"Webcam Full Screen"];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeRight)
    {
        pictureOr = UIImageOrientationLeft;
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        pictureOr = UIImageOrientationRight;
    } else if (orientation == UIDeviceOrientationUnknown)
    {
        pictureOr = UIImageOrientationLeft;
    }
}

- (void) notifyAboutBandwidth {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hintKey = @"bandwidth-hint";
    NSString *hintKeyString = @"shown";
    
    NSString *hint = [defaults objectForKey:hintKey];
    
    if ([hint isEqualToString:hintKeyString]) {
        // hint already shown
        // do nothing
    } else {
        if ([self dataNetworkTypeFromStatusBar] < DataNetworkWiFi) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Webcam Feed" message:@"Be aware, watching the webcam while not connected to WiFi will use mobile data which may be costly depending on your allowences." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
            
            hint = hintKeyString;
            [defaults setObject:hint forKey:hintKey];
            [defaults synchronize];
        }
    }
    
}

typedef enum {
    DataNetworkNone,
    DataNetwork2G,
    DataNetwork3G,
    DataNetwork4G,
    DataNetworkLTE,
    DataNetworkWiFi
} DataNetworkType;

- (DataNetworkType) dataNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]    subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    return [[dataNetworkItemView valueForKey:@"dataNetworkType"] intValue];
}

- (void) loadAdvertPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localPlistPath = [documentsDirectory stringByAppendingPathComponent:@"Adverts.plist"];
    
    NSArray *ads = [NSArray arrayWithContentsOfFile:localPlistPath];
    
    if (ads) {
        adverts = ads;
    } else {
        adverts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Advertising" ofType:@"plist"]];
    }
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        NSURL *remotePlistPath = [NSURL URLWithString:@"https://raw.github.com/RobertShippey/downhamweb-advert-file/master/Advertising.plist"];
        
        NSData *plistFileData = [[NSData alloc] initWithContentsOfURL:remotePlistPath];
        
        [plistFileData writeToFile:localPlistPath atomically:YES];
        
        adverts = [NSArray arrayWithContentsOfFile:localPlistPath];
        
    });
    
}


@end
