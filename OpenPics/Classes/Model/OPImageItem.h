//
//  OPImageItem.h
//
//  Created by PJ Gray on 4/4/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImageItem : NSObject

@property (strong, nonatomic) NSURL* imageUrl;
@property (strong, nonatomic) NSString* title;

- (id) initWithDictionary:(NSDictionary*) dict;

@end
