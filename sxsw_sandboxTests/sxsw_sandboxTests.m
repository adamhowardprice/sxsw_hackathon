//
//  sxsw_sandboxTests.m
//  sxsw_sandboxTests
//
//  Created by Adam Price on 3/8/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "sxsw_sandboxTests.h"
#import "Event.h"
#import "Event+SXSW.h"
#import "SPCoreDataWrapper.h"

@implementation sxsw_sandboxTests

- (void)setUp
{
    [super setUp];
    
    [SPCoreDataWrapper readContext]; // Sets up initial core data stack.
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConsumeJSONFromFile
{
    NSMutableArray *events = [NSMutableArray array];
    
    NSString *eventsDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"events"];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:eventsDirectory], @"%@ does not exist", eventsDirectory);
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:eventsDirectory];
    STAssertNotNil(enumerator, @"Directory Enumerator is nil");
    
    NSString *file;
    while (file = [enumerator nextObject]) {
        if ([[file pathExtension] isEqualToString:@"json"]) {
            NSData *fileData = [NSData dataWithContentsOfFile:[eventsDirectory stringByAppendingPathComponent:file]];
            STAssertNotNil(fileData, @"File Data is nil");
            NSError *error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
            if (error) NSLog(@"Error: %@", [error localizedDescription]);
            
            NSDictionary *eventDict = nil;
            if (jsonObject) {
                if ([jsonObject isKindOfClass:[NSArray class]]) {
                    Event *newEvent = [[Event alloc] initWithJSONArray:jsonObject inContext:[SPCoreDataWrapper readContext]];
                    
                    STAssertNotNil(newEvent, @"Event should not be nil");
                    [events addObject:newEvent];
                }
            }
        }
    }
    STAssertTrue([events count] > 0, @"There are 0 Event objects in the resulting array");
}

- (void)testDownloadMP3FromSXSW
{
    NSURL *url = [NSURL URLWithString:@"http://audio.sxsw.com/2013/mp3_by_artist_id/55492.mp3"];
    BOOL downloaded = [self downloadMP3sFromSXSWURL:url];
    STAssertTrue(downloaded, @"Did not download from URL: %@", [url absoluteString]);
}

#pragma mark Private Methods

- (BOOL)downloadMP3sFromSXSWURL:(NSURL *)inURL
{
    NSError *error = nil;
    NSData *songData = [NSData dataWithContentsOfURL:inURL options:0 error:&error];
    if (error)
        NSLog(@"Error: %@", [error localizedDescription]);
    return songData != nil && !error;
}

@end
