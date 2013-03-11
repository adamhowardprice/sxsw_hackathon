//
//  NSString+SXSW.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SXSW)

+ (NSString *)timeStringForDate:(NSDate *)date;
+ (NSUInteger)concertDayForDateString:(NSString *)dateString;
+ (NSString *)dateStringForConcertDay:(NSUInteger)index;

@end
