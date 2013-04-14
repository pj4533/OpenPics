//
//  OPImageItem.m
//
//  Created by PJ Gray on 4/4/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPImageItem.h"

@implementation OPImageItem

- (id) initWithDictionary:(NSDictionary*) dict {
    self = [super init];
    if (self) {
        self.imageUrl = dict[@"imageUrl"];
        self.title = dict[@"title"];
        self.providerSpecific = dict[@"providerSpecific"];
    }
    
    return self;
}


@end
