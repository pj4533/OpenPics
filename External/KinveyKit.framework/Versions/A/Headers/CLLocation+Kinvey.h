//
//  CLLocation+Kinvey.h
//  KinveyKit
//
//  Created by Michael Katz on 8/20/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/** Helper Category to allow for persisting CLLocation objects to the Kinvey backend.
 @since 1.8
 */
@interface CLLocation (Kinvey)
/** Converts this CLLocation to a form persistable to Kinvey.
 
 This saves a array in the longitude, latitude format, which is backwards from most CoreLocation methods. The long, lat order is necessary for geo queries in Kinvey.
 @since 1.8
 */
- (NSArray*) kinveyValue;

/** turns a serialized [longitude,latitude] array into a CLLocation object.
 @param kinveyValue an array object loaded from the backend.
 @return a new object represented by the array.
 @since 1.8
 */
+ (CLLocation*) locationFromKinveyValue:(NSArray*)kinveyValue;
@end
