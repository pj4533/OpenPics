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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.title = [decoder decodeObjectForKey:@"title"];
    self.imageUrl = [decoder decodeObjectForKey:@"imageUrl"];
    self.providerSpecific = [decoder decodeObjectForKey:@"providerSpecific"];
    self.location = CLLocationCoordinate2DMake([[decoder decodeObjectForKey:@"latitude"] floatValue], [[decoder decodeObjectForKey:@"longitude"] floatValue]);
    self.providerType = [decoder decodeObjectForKey:@"providerType"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [encoder encodeObject:self.providerSpecific forKey:@"providerSpecific"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.location.latitude] forKey:@"latitude"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.location.longitude] forKey:@"longitude"];
    [encoder encodeObject:self.providerType forKey:@"providerType"];
}


@end
