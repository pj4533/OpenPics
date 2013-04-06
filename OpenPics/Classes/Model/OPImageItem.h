//
//  OPImageItem.h
//
//  Created by PJ Gray on 4/4/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImageItem : NSObject

@property (strong, nonatomic) NSString* imageID;
@property (strong, nonatomic) NSString* itemLink;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* uuid;

- (id) initWithDictionary:(NSDictionary*) dict;

@end
