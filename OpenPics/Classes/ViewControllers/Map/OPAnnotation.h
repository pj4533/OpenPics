//
//  OPAnnotation.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSURL* imageUrl;
@property NSInteger index;
@property (nonatomic,copy) NSString *title;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location;


@end
