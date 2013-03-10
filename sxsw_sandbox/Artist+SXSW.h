//
//  Artist+SXSW.h
//  sxsw_sandbox
//
//  Created by Adam Price on 3/10/13.
//  Copyright (c) 2013 Adam Price. All rights reserved.
//

#import "Artist.h"

@interface Artist (SXSW)

- (id)initWithJSONDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

@end
