//
//  Venue+SXSW.m
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "Venue+SXSW.h"
#import "Event+SXSW.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

static NSDictionary *VenueMapppingDictionary = nil;
static CLGeocoder *_forwardGeocoder = nil;

@implementation Venue (SXSW)

+ (NSDictionary *)mappingDictionary
{
    if (!VenueMapppingDictionary) {
        VenueMapppingDictionary = @{@"address": @"address",
                                    @"name": @"name"};
    }
    return VenueMapppingDictionary;
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
             
             if ([propertyName isEqualToString:@"address"])
                 [self setForwaredGeocodedLatLngForAddress:tmpValue context:context];
         }
     }];
    
    return self;
}

- (void)setForwaredGeocodedLatLngForAddress:(NSString *)addressString context:(NSManagedObjectContext *)context
{
    if (!_forwardGeocoder)
        _forwardGeocoder = [[CLGeocoder alloc] init];
    
    __block Venue *selff = self;
    [_forwardGeocoder geocodeAddressString:[addressString stringByAppendingString:@", Austin, TX"]
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             CLPlacemark *pmark = [placemarks count] ? [placemarks lastObject] : nil;
                             if (pmark) {
                                 [selff setLat:@(pmark.location.coordinate.latitude)];
                                 [selff setLng:@(pmark.location.coordinate.longitude)];
                                 CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.lat floatValue], [self.lng floatValue]);
                                 for (Event *event in [selff.events allObjects])
                                     [event setCoordinate:coord];
                                 
                                 NSError *error = nil;
                                 [context save:&error];
                                 if (error) NSLog(@"Error: %@", [error localizedDescription]);
                             }
                         }];
}

@end
