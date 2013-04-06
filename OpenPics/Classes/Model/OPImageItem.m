//
//  OPImageItem.m
//
//  Created by PJ Gray on 4/4/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPImageItem.h"
#import "NSDictionary+SafeObjectForKey.h"

@implementation OPImageItem

- (id) initWithDictionary:(NSDictionary*) dict {
    self = [super init];
    if (self) {
        self.imageID =  [dict safeObjectForKey:@"imageID"];
        self.itemLink =  [dict safeObjectForKey:@"itemLink"];
        self.title =  [dict safeObjectForKey:@"title"];
        self.uuid =  [dict safeObjectForKey:@"uuid"];
    }
    
    return self;
}


@end
