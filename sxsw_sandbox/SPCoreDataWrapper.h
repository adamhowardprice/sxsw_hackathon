//
//  SPCoreDataWrapper.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Artist.h"
#import "Venue.h"
#import "Event.h"

@interface SPCoreDataWrapper : NSObject

+ (SPCoreDataWrapper *)sharedInstance;
+ (NSManagedObjectContext *)readContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSURL *)applicationDocumentsDirectory;
+ (void)saveContext;

// App Specific Methods
+ (void)seedCoreDataWithSXSWFilesIfNeeded;

// These methods create the object if they did not already exist
+ (Artist *)artistForEvent:(Event *)event
                      name:(NSString *)artistName
                       url:(NSString *)url
                     genre:(NSString *)genre
                     origin:(NSString *)origin
                     videoURL:(NSString *)videoURL
                     imgURL:(NSString *)imgURL
                   songURL:(NSString *)songURL
                 inContext:(NSManagedObjectContext *)context;
+ (Venue *)venueForEvent:(Event *)event
                    name:(NSString *)venueName
                 address:(NSString *)addressString
               inContext:(NSManagedObjectContext *)context;

+ (void)removeVenuesWithNoCoordinates;
@end
