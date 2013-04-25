//
//  OPAnnotation.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPAnnotation.h"
#import <CoreLocation/CoreLocation.h>

@implementation OPAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self != nil) {
        _coordinate = location;
        self.title = @" ";
    }
    return self;
}

@end
