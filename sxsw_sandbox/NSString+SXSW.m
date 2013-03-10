//
//  NSString+SXSW.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "NSString+SXSW.h"

@implementation NSString (SXSW)

+ (NSUInteger)concertDayForDateString:(NSString *)dateString
{
    NSUInteger date = -1;
    if ([dateString isEqualToString:@"2013-03-12"])
        date = 0;
    else if ([dateString isEqualToString:@"2013-03-13"])
        date = 1;
    else if ([dateString isEqualToString:@"2013-03-14"])
        date = 2;
    else if ([dateString isEqualToString:@"2013-03-15"])
        date = 3;
    else if ([dateString isEqualToString:@"2013-03-16"])
        date = 4;
    else if ([dateString isEqualToString:@"2013-03-17"])
        date = 5;
    return date;
}

+ (NSString *)dateStringForConcertDay:(NSUInteger)index
{
    NSString *dateString = nil;
    switch (index) {
        case 0:
            dateString = @"2013-03-12";
            break;
        case 1:
            dateString = @"2013-03-12";
        case 2:
            dateString = @"2013-03-12";
            break;
        case 3:
            dateString = @"2013-03-12";
        case 4:
            dateString = @"2013-03-12";
            break;
        case 5:
            dateString = @"2013-03-12";
        default:
            break;
    }
}

@end
