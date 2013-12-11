//
//  GoogCal.m
//  Election Map 2012
//
//  Created by Kurt Sparks on 2/1/12.
//  Copyright (c) 2012 none. All rights reserved.
//

#import "GoogCal.h"

#define kTitleKey @"GcalTitle"
#define kDescriptionKey @"GcalDescription"
#define kEndDateKey @"GcalEndDate"
#define kStartDateKey @"GcalStartDate"
#define kWhereKey @"GcalWhere"

@implementation GoogCal
@synthesize Title,Description, EndDate, StartDate, Where;

- (BOOL) isAllDay {
    
    if ([EndDate timeIntervalSinceDate:StartDate] == (60*60*24)) {
        return YES;
    } else if ([EndDate timeIntervalSinceDate:StartDate] > (60*60*24)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) isMultiDay {
    if ([EndDate timeIntervalSinceDate:StartDate] > (60*60*24)) {
        return YES;
    } else return NO;
}

// NSCoding methods

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:Title forKey:kTitleKey];
    [encoder encodeObject:Description forKey:kDescriptionKey];
    [encoder encodeObject:EndDate forKey:kEndDateKey];
    [encoder encodeObject:StartDate forKey:kStartDateKey];
    [encoder encodeObject:Where forKey:kWhereKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.Title = [decoder decodeObjectForKey:kTitleKey];
        self.Description = [decoder decodeObjectForKey:kDescriptionKey];
        self.StartDate = [decoder decodeObjectForKey:kStartDateKey];
        self.EndDate = [decoder decodeObjectForKey:kEndDateKey];
        self.Where = [decoder decodeObjectForKey:kWhereKey];
    }
    
    return self;
}

@end
