//
//  KinveyEntity.h
//  KinveyKit
//
//  Copyright (c) 2008-2013, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>
#import "KinveyPersistable.h"
#import "KCSClient.h"
#import "KCSBlockDefs.h"

#import "KinveyHeaderInfo.h"

/*!  Describes required selectors for requesting entities from the Kinvey Service.
*
* This Protocol should be implemented by a client for processing the results of an Entity request against the KCS
* service.
*/
@protocol KCSEntityDelegate <NSObject>

/*!
*  Called when a request fails for some reason (including network failure, internal server failure, request issues...)
 @param entity The Object that was attempting to be fetched.
 @param error The error that occurred
*/
- (void) entity: (id <KCSPersistable>)entity fetchDidFailWithError: (NSError *)error;

/*!
* Called when a request completes successfully.
 @param entity The Object that was attempting to be fetched.
 @param result The result of the completed request as an NSDictionary
*/
- (void) entity: (id <KCSPersistable>)entity fetchDidCompleteWithResult: (NSObject *)result;

@end

/*!  Add ActiveRecord-style capabilities to the built-in root object (NSObject) of the AppKit/Foundation system.
*
* This category is used to cause any NSObject to be able to be saved into the Kinvey Cloud Service.
*/
@interface NSObject (KCSEntity) <KCSPersistable>

/*! Fetch one instance of this entity from KCS (Depricated as of version 1.2)
*
* @param collection Collection to pull the entity from
* @param query Arbitrary JSON query to execute on KCS (See Queries in KCS documentation for details on Queries)
* @param delegate Delegate object to inform upon completion or failure of this request 
* @dprecated 1.2
*/
- (void)fetchOneFromCollection: (KCSCollection *)collection matchingQuery: (NSString *)query withDelegate: (id<KCSEntityDelegate>)delegate KCS_DEPRECATED(Deprecated,1.2);

/*! Fetch first entity with a given Boolean value for a property (Depricated as of version 1.2)
*
* @param property property to query
* @param value Boolean value (YES or NO) to query against value
* @param collection Collection to pull the entity from
* @param delegate Delegate object to inform upon completion or failure of this request
* @deprecated 1.2
*/
- (void)findEntityWithProperty: (NSString *)property matchingBoolValue: (BOOL)value fromCollection: (KCSCollection *)collection withDelegate: (id<KCSEntityDelegate>)delegate KCS_DEPRECATED(Deprecated,1.2);

/*! Fetch first entity with a given Double value for a property (Depricated as of version 1.2)
*
* @param property property to query
* @param value Real value to query against value
* @param collection Collection to pull the entity from
* @param delegate Delegate object to inform upon completion or failure of this request
* @deprecated 1.2
*/
- (void)findEntityWithProperty: (NSString *)property matchingDoubleValue: (double)value fromCollection: (KCSCollection *)collection withDelegate: (id<KCSEntityDelegate>)delegate KCS_DEPRECATED(Deprecated,1.2);

/*! Fetch first entity with a given Integer value for a property (Depricated as of version 1.2)
*
* @param property property to query
* @param value Integer to query against value
* @param collection Collection to pull the entity from
* @param delegate Delegate object to inform upon completion or failure of this request
* @deprecated 1.2
*/
- (void)findEntityWithProperty: (NSString *)property matchingIntegerValue: (int)value fromCollection: (KCSCollection *)collection withDelegate: (id<KCSEntityDelegate>)delegate  KCS_DEPRECATED(Deprecated,1.2);

/*! Fetch first entity with a given String value for a property (Depricated as of version 1.2)
*
* @param property property to query
* @param value String to query against value
* @param collection Collection to pull the entity from
* @param delegate Delegate object to inform upon completion or failure of this request
* @deprecated 1.2
*/
- (void)findEntityWithProperty: (NSString *)property matchingStringValue: (NSString *)value fromCollection: (KCSCollection *)collection withDelegate: (id<KCSEntityDelegate>)delegate KCS_DEPRECATED(Deprecated,1.2);

/*! Return the client property name for the kinvey id
 *
 * @returns the client property name for the kinvey id
 */
- (NSString *)kinveyObjectIdHostProperty;

/*! Return the `KCSEntityKeyId` value for this entity
*
* @returns the `KCSEntityKeyId` value for this entity.
*/
- (NSString *)kinveyObjectId;

/** Sets the `KCSEntityKeyId` value for this entity
 @param objId the string `_id` for the entity
 */
- (void) setKinveyObjectId:(NSString*) objId;

/*! Returns the value for a given property in this entity
*
* @param property The property that we're interested in.
* @returns the value of this property.
*/
//- (NSString *)valueForProperty: (NSString *)property;

/*! Set a value for a given property (Depricated as of version 1.2)
* @param value The value to set for the given property
* @param property The property to assign this value to.
*/
- (void)setValue: (NSString *)value forProperty: (NSString *)property;


/*! Load an entity with a specific ID and replace the current object
* @param objectID The ID of the entity to request
* @param collection Collection to pull the entity from
* @param delegate The delegate to notify upon completion of the load.
*/
- (void)loadObjectWithID: (NSString *)objectID fromCollection: (KCSCollection *)collection withDelegate:(id <KCSEntityDelegate>)delegate;

// Undocumented
- (void)saveToCollection: (KCSCollection *)collection
     withCompletionBlock: (KCSCompletionBlock)onCompletion
       withProgressBlock: (KCSProgressBlock)onProgress;

- (void)deleteFromCollection: (KCSCollection *)collection
         withCompletionBlock: (KCSCompletionBlock)onCompletion
           withProgressBlock: (KCSProgressBlock)onProgress;

@end
