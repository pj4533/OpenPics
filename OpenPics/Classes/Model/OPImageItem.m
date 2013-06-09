//
//  OPImageItem.m
//
//  Created by PJ Gray on 4/4/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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

        id providerUrlOrString = dict[@"providerUrl"];
        if ([providerUrlOrString isKindOfClass:[NSString class]]) {
            self.providerUrl = [NSURL URLWithString:providerUrlOrString];
        } else {
            self.providerUrl = providerUrlOrString;
        }
        self.title = dict[@"title"];
        self.providerSpecific = dict[@"providerSpecific"];
        self.location = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
        self.size = CGSizeMake([dict[@"width"] floatValue], [dict[@"height"] floatValue]);
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
    self.providerUrl = [decoder decodeObjectForKey:@"providerUrl"];
    self.providerSpecific = [decoder decodeObjectForKey:@"providerSpecific"];
    self.location = CLLocationCoordinate2DMake([[decoder decodeObjectForKey:@"latitude"] floatValue], [[decoder decodeObjectForKey:@"longitude"] floatValue]);
    self.providerType = [decoder decodeObjectForKey:@"providerType"];
    self.size = [decoder decodeCGSizeForKey:@"size"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [encoder encodeObject:self.providerUrl forKey:@"providerUrl"];
    [encoder encodeObject:self.providerSpecific forKey:@"providerSpecific"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.location.latitude] forKey:@"latitude"];
    [encoder encodeObject:[NSNumber numberWithFloat:self.location.longitude] forKey:@"longitude"];
    [encoder encodeObject:self.providerType forKey:@"providerType"];
    [encoder encodeCGSize:self.size forKey:@"size"];
}

- (BOOL)isEqual:(OPImageItem *)item {
    if (![item isKindOfClass:OPImageItem.class]) return NO;
    
    return [self.imageUrl isEqual:item.imageUrl] && [self.title isEqual:item.title];
}


@end
