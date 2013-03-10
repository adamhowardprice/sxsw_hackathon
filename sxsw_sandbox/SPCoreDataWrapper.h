//
//  SPCoreDataWrapper.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPCoreDataWrapper : NSObject

+ (SPCoreDataWrapper *)sharedInstance;
+ (NSManagedObjectContext *)readContext;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSURL *)applicationDocumentsDirectory;
+ (void)saveContext;

@end
