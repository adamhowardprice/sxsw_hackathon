//
//  Event+SXSW.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "Event.h"

@interface Event (SXSW)

+ (NSDictionary *)mappingDictionary;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

@end
