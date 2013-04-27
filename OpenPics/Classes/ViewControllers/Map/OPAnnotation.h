//
//  OPAnnotation.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPImageItem;
@interface OPAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;

@property (strong, nonatomic) OPImageItem* item;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location;


@end
