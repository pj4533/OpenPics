//
//  NSDictionary+DefObject.m
//  OpenPics
//
//  Created by PJ Gray on 4/20/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "NSDictionary+DefObject.h"

@implementation NSDictionary (DefObject)

- (id) defObjectForKey:(NSString*) key {
    
    NSDictionary* keyDict = self[key];
    NSArray* defArray = keyDict[@"def"];
    if (defArray && defArray.count) {
        return defArray[0];
    }
    
    return nil;
}


@end
