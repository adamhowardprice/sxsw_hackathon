//
//  Event.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/8/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    NSString *_url;
    NSString *_artist;
    NSString *_venue;
    NSString *_day;
    NSDate *_startDate;
    NSDate *_endDate;
    NSString *_ages;
    NSArray *_hashTagsArray;
}
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *venue;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *ages;
@property (nonatomic, strong) NSArray *hashTagsArray;

+ (NSDictionary *)mappingDictionary;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
