//
//  GoogCal.h
//  Election Map 2012
//
//  Created by Kurt Sparks on 2/1/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogCal : NSObject <NSCoding>

@property (nonatomic, retain) NSString *Title;
@property (nonatomic, retain) NSDate *StartDate;
@property (nonatomic, retain) NSDate *EndDate;
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, retain) NSString *Where;

- (BOOL) isAllDay;
- (BOOL) isMultiDay;

@end
