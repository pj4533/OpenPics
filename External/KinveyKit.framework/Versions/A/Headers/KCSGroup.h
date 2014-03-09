//
//  KCSGroup.h
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
 A KCSGroup is the object that wraps the response of a KCSStore's groupBy: call. 
 */
@interface KCSGroup : NSObject

- (instancetype) initWithJsonArray:(NSArray*)jsonData valueKey:(NSString*)key queriedFields:(NSArray*)fields;

/**
 Returns the raw array. Each group will be represented by a dictionary in that array, where the keys are the fields that they are grouped by, plus one field for the return value. 
 
 For each field-key the value in the dictionary is the value for that group. This array only contains groupings of fields where the condition was met and there was at least one object that matched the fields. The return value field is named according to returnValueKey, and the value is object representing the reduced value.  
 @return the array of grouped values.
 */
- (NSArray*) fieldsAndValues;

/**
 This is what the KCSReduceFunction named the output field. This value changes depending on the function type and input field names. 
 @return the name of the key for the reduce function return value
 */
- (NSString*) returnValueKey;

/**
 A handy way to enumerate over the whole returned array. The fieldValues will be just the queried field values, in the same order that the fields were specified to the store's groupBy: function. 
 
 See [NSArray enumerateWithBlock:] for how idx and stop work. 
 @param block The enumeration block. `fieldValues` are the values of the grouped fields, `value` is the value object for the reduce function for that group, `idx` is an integer index into the array of returned values, and setting `stop` to true will end the enumeration.
 */
- (void) enumerateWithBlock:(void (^)(NSArray* fieldValues, id value, NSUInteger idx, BOOL *stop))block;

/**
 Grabs just the value object that satisifies the specified fields.
 @param fields This dictionary should have the field name as a key and the grouped value as the value object. 
 @return the value object that matches the specified field-values. Returns a NSNumber with intValue of `NSNotFound` if no value found. 
 */
- (id) reducedValueForFields:(NSDictionary*)fields; 

@end
