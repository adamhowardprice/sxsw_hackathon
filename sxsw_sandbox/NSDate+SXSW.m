//
//  NSDate+SXSW.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "NSDate+SXSW.h"

static NSDateFormatter *dateFormatter = nil;

@implementation NSDate (SXSW)

+ (NSDate *)dateFromISODateString:(NSString *)dateString
{
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

@end
