//
//  KCSReduceFunction.h
//  KinveyKit
//
//  Copyright (c) 2012-2013 Kinvey, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>

/**
 The purpose of this object is to represent the reduce function applied to a collection when using `KCSStore`'s groupBy: method. 
 */
@interface KCSReduceFunction : NSObject
{
    NSString* _jsonRepresentation;
    id _jsonInitValue;
    NSString* _outputField;
}
/** @name Predefined functions */

/** Function for counting all elements in the group. */
+ (KCSReduceFunction*) COUNT;
/** Function to sum together all the numeric values in the specified field.
 @param fieldToSum is the collection objects' field to add together. 
 */
+ (KCSReduceFunction*) SUM:(NSString*)fieldToSum;
/** Function to find the minimum value for the specified field in each group.
 @param fieldToMin is the collection objects' field to find the minimum.
 */
+ (KCSReduceFunction*) MIN:(NSString*)fieldToMin;
/** Function to find the maximum value for the specified field in each group.
 @param fieldToMax is the collection objects' field to find the maximum.
 */
+ (KCSReduceFunction*) MAX:(NSString*)fieldToMax;
/** Function to find the average value for the specified field in each group.
 @param fieldToAverage is the collection object's field to find the average.
 */
+ (KCSReduceFunction*) AVERAGE:(NSString*)fieldToAverage;

/** Function to collect all the objects for a particular field value.
 
 This is a useful function for obtaining objects for sectioned tables. 
 @since 1.14.0
 */
+ (KCSReduceFunction*) AGGREGATE;

- (NSString *)JSONStringRepresentationForFunction:(NSArray*)fields;
- (NSDictionary *)JSONStringRepresentationForInitialValue:(NSArray*)fields;
- (NSString*)outputValueName:(NSArray*)fields;

@end
