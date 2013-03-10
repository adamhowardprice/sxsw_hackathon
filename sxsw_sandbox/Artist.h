//
//  Artist.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSString * imgURL;
@property (nonatomic, retain) NSString * songURL;
@property (nonatomic, retain) NSSet *events;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
