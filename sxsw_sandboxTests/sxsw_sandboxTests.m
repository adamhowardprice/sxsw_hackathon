//
//  sxsw_sandboxTests.m
//  sxsw_sandboxTests
//
//  Created by Adam Price on 3/8/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "sxsw_sandboxTests.h"
#import "Event.h"

@implementation sxsw_sandboxTests

- (void)setUp
{
    [super setUp];
    
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
                    STAssertTrue([jsonObject isKindOfClass:[NSArray class]] && [(NSArray *)jsonObject count] > 0, @"JSON Object should be an NSArray or it should have count > 0: %@", jsonObject);
                    eventDict = [(NSArray *)jsonObject objectAtIndex:0];
                }
                else if ([jsonObject isKindOfClass:[NSDictionary class]])
                    eventDict = jsonObject;
                
                Event *newEvent = [[Event alloc] initWithJSONDictionary:eventDict];
                STAssertNotNil(newEvent, @"Event should not be nil");
                [events addObject:newEvent];
            }
        }
    }
    STAssertTrue([events count] > 0, @"There are 0 Event objects in the resulting array");
}

@end
