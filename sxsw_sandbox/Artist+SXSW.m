//
//  Artist+SXSW.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "Artist+SXSW.h"

static NSDictionary *ArtistMapppingDictionary = nil;

@implementation Artist (SXSW)

+ (NSDictionary *)mappingDictionary
{
    if (!ArtistMapppingDictionary) {
        ArtistMapppingDictionary = @{@"name": @"name",
                                     @"url": @"url",
                                     @"genre": @"genre",
                                     @"origin": @"origin",
                                     @"videoURL": @"videoURL",
                                     @"imgURL": @"imgURL",
                                     @"songURL": @"songURL"
                                     };
    }
    return ArtistMapppingDictionary;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context
{
    if (!(self = [super initWithEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context] insertIntoManagedObjectContext:context]))
        return nil;
    
    [[[self class] mappingDictionary] enumerateKeysAndObjectsUsingBlock:
     ^(id serverKey, id propertyName, BOOL *stop)
     {
         id tmpValue = dictionary[serverKey];
         if (tmpValue && tmpValue != [NSNull null]) {
             [self setValue:tmpValue forKey:propertyName];
         }
     }];
    
    return self;
}

@end
