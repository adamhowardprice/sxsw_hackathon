//
//  Event+SXSW.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "Event+SXSW.h"
#import "Artist+SXSW.h"
#import "Venue+SXSW.h"
#import "NSDate+SXSW.h"
#import "SPCoreDataWrapper.h"
#import "Artist.h"
#import "Venue.h"
#include <time.h>
#include <xlocale.h>

#define SP_ISO8601_MAX_LENGTH 25

// Adopted from SSToolkit NSDate+SSToolkitAdditions
// Created by Sam Soffes
// Copyright (c) 2008-2012 Sam Soffes
// https://github.com/soffes/sstoolkit/
NSDate * SPDateFromISO8601String(NSString *ISO8601String) {
    if (!ISO8601String) {
        return nil;
    }
    
    const char *str = [ISO8601String cStringUsingEncoding:NSUTF8StringEncoding];
    char newStr[SP_ISO8601_MAX_LENGTH];
    bzero(newStr, SP_ISO8601_MAX_LENGTH);
    
    size_t len = strlen(str);
    if (len == 0) {
        return nil;
    }
    
    // UTC dates ending with Z
    if (len == 20 && str[len - 1] == 'Z') {
        memcpy(newStr, str, len - 1);
        strncpy(newStr + len - 1, "+0000\0", 6);
    }
    
    // Timezone includes a semicolon (not supported by strptime)
    else if (len == 25 && str[22] == ':') {
        memcpy(newStr, str, 22);
        memcpy(newStr + 22, str + 23, 2);
    }
    
    // Fallback: date was already well-formatted OR any other case (bad-formatted)
    else {
        memcpy(newStr, str, len > SP_ISO8601_MAX_LENGTH - 1 ? SP_ISO8601_MAX_LENGTH - 1 : len);
    }
    
    // Add null terminator
    newStr[sizeof(newStr) - 1] = 0;
    
    struct tm tm = {
        .tm_sec = 0,
        .tm_min = 0,
        .tm_hour = 0,
        .tm_mday = 0,
        .tm_mon = 0,
        .tm_year = 0,
        .tm_wday = 0,
        .tm_yday = 0,
        .tm_isdst = -1,
    };
    
    strptime_l(newStr, "%Y-%m-%d %H:%M:%S %z", &tm, NULL);
    
    return [NSDate dateWithTimeIntervalSince1970:mktime(&tm)];
}


static NSDictionary *EventMapppingDictionary = nil;

@implementation Event (SXSW)

+ (NSDictionary *)mappingDictionary
{
    if (!EventMapppingDictionary) {
        EventMapppingDictionary = @{
                                    @"url": @"url",
                                    @"artist": @"artist",
                                    @"venue": @"venue",
                                    @"day": @"day",
                                    @"ages": @"ages",
                                    @"start": @"startDate",
                                    @"end": @"endDate"
                                    };
    }
    return EventMapppingDictionary;
}

- (id)initWithJSONArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    if (!(self = [super initWithEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context] insertIntoManagedObjectContext:context]))
        return nil;
    
    NSDictionary *eventDict = [array count] ? array[0] : nil;
    NSDictionary *artistDict = [array count] >= 1 ? array[1] : nil;
    NSDictionary *venueDict = [array count] >= 2 ? array[2] : nil;
    
    if (eventDict) {
        [[[self class] mappingDictionary] enumerateKeysAndObjectsUsingBlock:
         ^(id serverKey, id propertyName, BOOL *stop)
         {
             id tmpValue = eventDict[serverKey];
             if (tmpValue && tmpValue != [NSNull null]) {
                 if ([propertyName hasSuffix:@"Date"] || [propertyName hasSuffix:@"Date"])
                 {
                     // tmpValue = SPDateFromISO8601String(tmpValue);
                     static NSDateFormatter* formatter = nil;
                     if (!formatter) {
                         formatter = [[NSDateFormatter alloc] init];
                         formatter.locale = [NSLocale autoupdatingCurrentLocale];
                         formatter.timeZone = [NSTimeZone localTimeZone];
                         
                         /*2013-03-14T06:50:00Z*/
                         formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
                     }
                     tmpValue = [formatter dateFromString:tmpValue];
                 }
                 
                 if ([propertyName isEqualToString:@"artist"] || [propertyName isEqualToString:@"venue"]) {
                     if ([propertyName isEqualToString:@"artist"])
                     {
                         
                         tmpValue = [SPCoreDataWrapper artistForEvent:self
                                                                 name:artistDict[@"name"]
                                                                  url:artistDict[@"url"]
                                                                genre:artistDict[@"genre"]
                                                               origin:artistDict[@"origin"]
                                                             videoURL:artistDict[@"videoURL"]
                                                               imgURL:artistDict[@"imgURL"]
                                                              songURL:artistDict[@"songURL"]
                                                            inContext:context];
                         
                     }
                     else if ([propertyName isEqualToString:@"venue"])
                     {
                         tmpValue = [SPCoreDataWrapper venueForEvent:self
                                                                name:tmpValue
                                                             address:venueDict[@"address"]
                                                           inContext:context];
                     }
                 }
                 
                 [self setValue:tmpValue forKey:propertyName];
             }
         }];
    }
    
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"\nurl: '%@',\nartist: '%@',\nstartDate: '%@',\nendDate: '%@'", self.url, self.artist, self.startDate, self.endDate];
}

#pragma mark MKAnnotation

- (NSString *)title
{
    return self.artist.name;
}

- (NSString *)subtitle
{
    return self.venue.address;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.venue.lat doubleValue], [self.venue.lng doubleValue]);
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    if (CLLocationCoordinate2DIsValid(newCoordinate)) {
        [self.venue setLat:@(newCoordinate.latitude)];
        [self.venue setLng:@(newCoordinate.longitude)];
    }
}

- (BOOL)isHappeningAtDate:(NSDate *)date
{
    return [self.endDate timeIntervalSinceDate:date] > 0 && [self.startDate timeIntervalSinceDate:date] < 0;
}

@end
