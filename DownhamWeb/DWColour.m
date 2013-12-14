//
//  DWColour.m
//  DownhamWeb
//
//  Created by Robert Shippey on 01/09/2013.
//  Copyright (c) 2013 DownhamWeb. All rights reserved.
//

#import "DWColour.h"

@implementation DWColour

+ (UIColor *) purple {
    return [UIColor colorWithRed:66.0/255.0 green:51.0/255.0 blue:160.0/255.0 alpha:1];
}

+ (UIColor *) white {
    return [UIColor whiteColor];
}

+ (UIColor *) black {
    return [UIColor blackColor];
}

+ (UIColor *) clear {
    return [UIColor clearColor];
}

+ (UIColor *) orange {
    return [UIColor orangeColor];
}

+ (UIColor *) errorRed {
    return [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:82.0/255.0 alpha:1.0];
}

+ (UIColor *) green {
    return [UIColor colorWithRed:30.0/255.0 green:190.0/255.0 blue:57.0/255.0 alpha:1.0];
}

@end
