//
//  AppDelegate.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/8/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "AppDelegate.h"
#import "SPCoreDataWrapper.h"
#import <CocoaLibSpotify.h>
#import "MBProgressHUD.h"
#import "appkey.h"

#define kDefaultSpotifyUserCredentials @"SpotifyUser"
#define SP_LIBSPOTIFY_DEBUG_LOGGING 0

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize rootVC = _rootVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    _rootVC = [[RootVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_rootVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    [self setupSpotify];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    [SPCoreDataWrapper saveContext];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    return [SPCoreDataWrapper readContext];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    return [SPCoreDataWrapper managedObjectModel];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return [SPCoreDataWrapper persistentStoreCoordinator];
}

#pragma mark - CocoaLibSpotify

#pragma mark Utils

- (void)setupSpotify
{
	NSString *userAgent = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
	NSData *appKey = [NSData dataWithBytes:&g_appkey length:g_appkey_size];
    
	NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:appKey
											   userAgent:userAgent
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    
	[[SPSession sharedSession] setDelegate:self];
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
    if (![self maybeAutologin]) {
        SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
        controller.allowsCancel = NO;
        // ^ To allow the user to cancel (i.e., your application doesn't require a logged-in Spotify user, set this to YES.
        [_rootVC.navigationController presentViewController:controller animated:NO completion:nil];
    }
    
    
    [SPCoreDataWrapper seedCoreDataWithSXSWFilesIfNeeded];
}

- (BOOL)maybeAutologin
{
    NSDictionary* user = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kDefaultSpotifyUserCredentials];
    if (!user) {
        return NO;
    }
    
    [[SPSession sharedSession] attemptLoginWithUserName:[[user allKeys] lastObject] existingCredential:[[user allValues] lastObject]];
    
    // TODO: show modal login activity indicator
    [MBProgressHUD showHUDAddedTo:_rootVC.view animated:NO];
    
    return YES;
}

#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
	// Called after a successful login.
    
    [MBProgressHUD hideAllHUDsForView:_rootVC.view animated:YES];
    
	[SPAsyncLoading waitUntilLoaded:aSession timeout:kSPAsyncLoadingDefaultTimeout then:^
     (NSArray *loadedItems, NSArray *notLoadedItems) {
         if (![loadedItems containsObject:aSession]) {
             [NSException raise:@"Session failed to load" format:@"Not loaded items %@", notLoadedItems];
         }
         
         [SPAsyncLoading waitUntilLoaded:aSession.user timeout:kSPAsyncLoadingDefaultTimeout then:^
          (NSArray *loadedItems, NSArray *notLoadedItems) {
              if (![loadedItems containsObject:aSession.user]) {
                  [NSException raise:@"Session user failed to load" format:@"Not loaded items %@", notLoadedItems];
              }
              
              if (_rootVC.navigationController.presentedViewController) {
                  [_rootVC.navigationController dismissViewControllerAnimated:YES completion:nil];
                  return;
              }
          }];
     }];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
	// Called after a failed login. SPLoginViewController will deal with this for us.
    if ([_rootVC.navigationController.presentedViewController isKindOfClass:[SPLoginViewController class]]) {
        return;
    }
    
    SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
    controller.allowsCancel = NO;
    // ^ To allow the user to cancel (i.e., your application doesn't require a logged-in Spotify user, set this to YES.
    [_rootVC.navigationController presentViewController:controller animated:YES completion:nil];
}

-(void)sessionDidLogOut:(SPSession *)aSession; {
	// Called after a logout has been completed.
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    
	// Called when login credentials are created. If you want to save user logins, uncomment the code below.
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *storedCredentials = [[defaults valueForKey:kDefaultSpotifyUserCredentials] mutableCopy];
    
	if (storedCredentials == nil)
		storedCredentials = [NSMutableDictionary dictionary];
    
	[storedCredentials setValue:credential forKey:userName];
	[defaults setValue:storedCredentials forKey:kDefaultSpotifyUserCredentials];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {
	if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
		NSLog(@"CocoaLS NETWORK ERROR: %@", error);
}

-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {
	if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
		NSLog(@"CocoaLS DEBUG: %@", aMessage);
}

-(void)sessionDidChangeMetadata:(SPSession *)aSession; {
	// Called when metadata has been updated somewhere in the
	// CocoaLibSpotify object model. You don't normally need to do
	// anything here. KVO on the metadata you're interested in instead.
}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	// Called when the Spotify service wants to relay a piece of information to the user.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"From Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

@end
