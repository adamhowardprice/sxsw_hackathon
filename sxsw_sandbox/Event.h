//
//  Event.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Venue;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * ages;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) Venue *venue;

@end
