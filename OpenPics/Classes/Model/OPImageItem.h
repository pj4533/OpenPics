//
//  OPImageItem.h
//
//  Created by PJ Gray on 4/4/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPImageItem : NSObject <NSCoding>

@property (strong, nonatomic) NSURL* providerUrl;
@property (strong, nonatomic) NSURL* imageUrl;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSDictionary* providerSpecific;
@property (strong, nonatomic) NSString* providerType;

@property CLLocationCoordinate2D location;
@property CGSize size;

- (id) initWithDictionary:(NSDictionary*) dict;

@end
