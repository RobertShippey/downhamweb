//
//  DWBusinessPoint.m
//  DownhamWeb
//
//  Created by Robert Shippey on 03/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWBusinessPoint.h"

@implementation DWBusinessPoint {
    NSString *businessTitle;
    NSString *businessCategory;
    NSString *email;
    NSString *phone;
    NSString *address;
    NSString *businessDescription;
}

- (id) initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
    businessTitle =  [dict objectForKey:@"Name"];
    businessCategory = [dict objectForKey:@"Category"];
    
    phone = [dict objectForKey:@"PhoneNo"];
    email = [dict objectForKey:@"email"];
    address = [dict objectForKey:@"Address"];
    businessDescription = [dict objectForKey:@"Description"];
    
    double locLong = [[dict objectForKey:@"Long"] doubleValue];
    double locLat = [[dict objectForKey:@"Lat"] doubleValue];
    CLLocationCoordinate2D location = {locLat,locLong};
    self.coordinate = location;
    
    return self;
}

- (NSString *) title {
    return businessTitle;
}

- (NSString *) subtitle {
    return businessCategory;
}

- (NSString *) phoneNumber {
    return phone;
}

- (NSString *) emailAddress {
    return email;
}

- (NSString *)address {
    if (address.length != 0) {
        return address;
    } else {
        return @"No address available.";
    }
}

- (NSString *) businessDescription {
    
    if (businessDescription.length != 0) {
        return businessDescription;
    } else {
        return @"No description available.";
    }
}

+ (void) reloadBusinessListings {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localPlistPath = [documentsDirectory stringByAppendingPathComponent:@"Businesses.plist"];
    
    BOOL shouldReload = NO;
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"DWBusinessReloadTime"];
    if (date) {
        if (abs([date timeIntervalSinceNow]) > 60*60*24 ) {
            shouldReload = YES;
        }
    } else {
        shouldReload = YES;
    }
    
    if (shouldReload) {
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            
            NSURL *remotePlistPath = [NSURL URLWithString:@""];
            
            NSData *plistFileData = [[NSData alloc] initWithContentsOfURL:remotePlistPath];
            
            [plistFileData writeToFile:localPlistPath atomically:YES];
            
        });
    }
    
    
}

@end
