//
//  CLLocation+Kinvey.h
//  KinveyKit
//
//  Copyright (c) 2012-2014 Kinvey. All rights reserved.
//
// This software is licensed to you under the Kinvey terms of service located at
// http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
// software, you hereby accept such terms of service  (and any agreement referenced
// therein) and agree that you have read, understand and agree to be bound by such
// terms of service and are of legal age to agree to such terms with Kinvey.
//
// This software contains valuable confidential and proprietary information of
// KINVEY, INC and is subject to applicable licensing agreements.
// Unauthorized reproduction, transmission or distribution of this file and its
// contents is a violation of applicable laws.
//

#import <CoreLocation/CoreLocation.h>

/** Convert a CLLocationCoordinate2D to the Kinvey representation;
 @since 1.26.0
 */
NSArray* CLLocationCoordinate2DToKCS(CLLocationCoordinate2D coordinate);

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
