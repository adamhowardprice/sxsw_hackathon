//
//  AppDelegate.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/8/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootVC.h"

@class SPPlaybackManager;
@protocol SPSessionDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) SPPlaybackManager* playbackManager;
@property (nonatomic, strong) RootVC *rootVC;

@end
