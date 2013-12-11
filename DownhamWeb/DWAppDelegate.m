//
//  DWAppDelegate.m
//  DownhamWeb
//
//  Created by Robert Shippey on 20/05/2013.
//

#import "DWAppDelegate.h"
#import "DWEventDetailsViewController.h"
#import "DWCalendarViewController.h"
#import "Appirater.h"

@implementation DWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Appirater setAppId:@"687495511"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:20];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2.5];
    [Appirater setDebug:NO];
    
    //    UIStoryboard *mainStoryboard = nil;
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    //        mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard-iOS7" bundle:nil];
    //    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
    //        mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard-iOS6" bundle:nil];
    //    } else {
    //        mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard-iOS5" bundle:nil];
    //    }
    //
    //    UIViewController *initialViewController = [mainStoryboard instantiateInitialViewController];
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //    self.window.rootViewController = initialViewController;
    //    [self.window makeKeyAndVisible];
    
    [Mixpanel sharedInstanceWithToken:@"257ca3765df0972d52fb46322879ebb1"];
    [[Mixpanel sharedInstance] registerSuperProperties:@{@"DeviceModel":[[UIDevice currentDevice] model],
                                                         @"DeviceVersion":[[UIDevice currentDevice] systemVersion]}];
    [[Mixpanel sharedInstance] identify:[[Mixpanel sharedInstance] distinctId]];
    [[[Mixpanel sharedInstance] people] increment:@"ApplicationLoads" by:@1];
    
    //#warning remember to comment out for App Store / uncomment for TestFlight
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"436addf7-2d01-4344-a71b-919668c8b351"];
    
    //[self.window setTintColor:dwColour];
    
    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:[DWColour white]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [DWColour purple]}];
    [[UINavigationBar appearance] setTintColor:[DWColour purple]];
    
    [[UITabBar appearance] setBarTintColor:[DWColour white]];
    [[UITabBar appearance] setTintColor:[DWColour purple]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [DWColour purple]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} forState:UIControlStateNormal];
    
    UILocalNotification *localNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [self application:[UIApplication sharedApplication] didReceiveLocalNotification:localNotif];
    }
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    if (app) {
        [app cancelLocalNotification:notif];
    } else {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
    
    [[Mixpanel sharedInstance] track:@"NotificationTapped"];
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder" message:notif.alertBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    //    [alert show];
    
    [TestFlight passCheckpoint:@"opened app from notification"];
    [Appirater appLaunched:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
