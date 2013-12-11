//
//  DWBusinessPoint.h
//  DownhamWeb
//
//  Created by Robert Shippey on 03/12/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DWBusinessPoint : MKPointAnnotation

- (instancetype) initWithDictionary:(NSDictionary *)dict;

- (NSString *) title;
- (NSString *) subtitle;

- (NSString *)phoneNumber;
- (NSString *)emailAddress;
- (NSString *)address;
- (NSString *)businessDescription;

@end
