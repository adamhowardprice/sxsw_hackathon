//
//  SPCoreDataWrapper.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "SPCoreDataWrapper.h"

static SPCoreDataWrapper *_sharedInstance = nil;
static NSManagedObjectContext *_moc = nil;
static NSManagedObjectModel *_mom = nil;
static NSPersistentStoreCoordinator *_psc = nil;

@interface SPCoreDataWrapper ()
+ (SPCoreDataWrapper *)sharedInstance;

@end

@implementation SPCoreDataWrapper

+ (SPCoreDataWrapper *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,^ {
					  _sharedInstance = [[self alloc] init];
				  });
	return _sharedInstance;
}

- (id)init
{
	if (!(self = [super init]))
        return nil;
    
    return self;
}

#pragma mark Core Data Objects

+ (NSManagedObjectContext *)readContext
{
	if (_moc != nil)
        return _moc;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_moc setPersistentStoreCoordinator:coordinator];
		[_moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }
	
    return _moc;
}

+ (NSManagedObjectModel *)managedObjectModel
{
	if (_mom != nil)
        return _mom;
    
    @try {
		_mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
        _mom = nil;
    }
    return _mom;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_psc != nil) {
        return _psc;
    }
    
    NSURL *storeURL = [[[self class] applicationDocumentsDirectory] URLByAppendingPathComponent:@"sxsw_sandbox.sqlite"];
    
    NSError *error = nil;
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _psc;
}

+ (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self readContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
