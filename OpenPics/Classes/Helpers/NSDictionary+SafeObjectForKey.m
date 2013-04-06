//
//  NSDictionary+SafeObjectForKey.m
//  ET
//
//  Created by PJ Gray on 11/3/12.
//  Copyright (c) 2012 EverTrue. All rights reserved.
//

#import "NSDictionary+SafeObjectForKey.h"

@implementation NSDictionary (SafeObjectForKey)

- (id) safeObjectForKey:(NSString*) key {
    if ([self objectForKey:key] && ([self objectForKey:key] != [NSNull null])) {
        if ([[self objectForKey:key] isKindOfClass:[NSString class]]) {
            if ([[self objectForKey:key] isEqualToString:@"<null>"]) {
                return nil;
            } else
                return [self objectForKey:key];
        } else
            return [self objectForKey:key];
    } else
        return nil;
}

@end
