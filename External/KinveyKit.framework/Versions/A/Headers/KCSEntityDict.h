//
//  KCSEntityDict.h
//  KinveyKit
//
//  Copyright (c) 2008-2012, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>
#import "KinveyEntity.h"
#import "KinveyPersistable.h"
#import "KCSClient.h"

/*! An entity dictionary object that can save to Kinvey.

	To use this object, simply treat it as a dictionary and issue a fetch/save to update it's
	data from Kinvey.
 
 KCSEntityDict has been deprecated because of it adds unnecessary overhead. Just use a `NSMutableDictionary` instead (Note: using a non-mutable `NSDictionary` will not have its fields updated when saving the object).
 
 @deprecatedIn 1.9
*/
@interface KCSEntityDict : NSObject <KCSPersistable>  

/*! The ObjectID for this dictionary, if the objectID is not set when saving to a collection one will be generated. */
@property (nonatomic, retain) NSString *objectId DEPRECATED_ATTRIBUTE;


/*! Return the value for an attribute for this user
 *
 * @deprecatedIn 1.9
 * @param property The attribute to retrieve
 */
- (id)getValueForProperty: (NSString *)property DEPRECATED_ATTRIBUTE;

/*! Set the value for an attribute
 *
 * @deprecatedIn 1.9
 * @param value The value to set.
 * @param property The attribute to modify.
 */
- (void)setValue: (id)value forProperty:(NSString *)property DEPRECATED_ATTRIBUTE;

- (id) init __attribute__((deprecated("KCSEntityDict is deprecated, use NSMutableDictionary instead.")));

@end

/**
 Category to support using NS(Mutable)Dictionary objects as first-class Kinvey Entities.

 @since 1.9
 */
@interface NSDictionary (KCSEntityDict) <KCSPersistable>

@end
