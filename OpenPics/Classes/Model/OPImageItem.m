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
        id imageUrlOrString = dict[@"imageUrl"];

        if ([imageUrlOrString isKindOfClass:[NSString class]]) {
            self.imageUrl = [NSURL URLWithString:imageUrlOrString];
        } else {
            self.imageUrl = imageUrlOrString;
        }
        
        self.title = dict[@"title"];
        self.providerSpecific = dict[@"providerSpecific"];
        self.location = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
        self.providerType = dict[@"providerType"];
    }
    
    return self;
}


@end
