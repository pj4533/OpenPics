//
//  NSDictionary+SafeObjectForKey.h
//  ET
//
//  Created by PJ Gray on 11/3/12.
//  Copyright (c) 2012 EverTrue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeObjectForKey)

- (id) safeObjectForKey:(NSString*) key;

@end
