//
//  KCSMetadata.h
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

#import <Foundation/Foundation.h>

#import "KinveyHeaderInfo.h"

/** Fieldname to access an object's creator, using KCSQuery.
 @since 1.10.2
 */
KCS_CONSTANT KCSMetadataFieldCreator;
/** Fieldname to access an object's last modified time, using KCSQuery.
 @since 1.10.2
 */
KCS_CONSTANT KCSMetadataFieldLastModifiedTime;
/** Fieldname to access an object's entity creation time, using KCSQuery.
 @since 1.14.2
 */
KCS_CONSTANT KCSMetadataFieldCreationTime;

/** This object represents backend information about the entity, such a timestamp and read/write permissions.
 
 To take advantage of KCSMetadata, map an entity property of this type to field `KCSEntityKeyMetadata`. The object that maps a particular instance is the "associated object." 
 */
@interface KCSMetadata : NSObject <NSCopying, NSCoding>

/** The array of users with explicit read access.
 
 This can be used to give a list of user `_id`'s for users that can read the associated object, even if the collection access does not grant read permissions generally.
 */
@property (nonatomic, strong, readonly) NSMutableArray* readers;

/** The array of users with explicit write access.
 
 This can be used to give a list of user `_id`'s for users that can write to the associated object, even if the collection access does not grant write permissions generally. The user must also be in the readers to list to read the object. 
 */
@property (nonatomic, strong, readonly) NSMutableArray* writers;
 
/** @name Basic Metadata */

/** The time at which the server recorded the most recent change to the entity. 
 @return the server time when the entity was last saved
 @see creationTime;
 */
- (NSDate*) lastModifiedTime;

/** The time at which the server the entity's creation.
 @return the server time when the entity was created. Nil if the object was created before Kinvey data store started to keep track of this value. 
 @see lastModifiedTime;
 @since 1.14.2
 */
- (NSDate*) creationTime;

/** The id of the user that created the associated entity
 @return the user id that created the entity
 */
- (NSString*) creatorId;

/** @name read/write permissions */

/** 
 A quick test to see the current user can make changes to the associated object. This only takes into account permissions set on the metadata. The user may still have access to change the entity if the collection grants broader write access to its entities.  
 */
- (BOOL) hasWritePermission;

/** The global read permission for the associated entity. This could be broader or more restrictive than its collection's permissions.
 @return `YES` if the entity can be read by any user
 @see setGloballyReadable:
 */
- (BOOL) isGloballyReadable;

/** Set global read permission for the associated object.
 
 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param readable `YES` to allow the associated object to be read by any user.
 @see isGloballyReadable
*/
- (void) setGloballyReadable:(BOOL)readable;

/** The global write permission for the associated entity. This could be broader or more restrictive than its collection's permissions.
 @return `YES` if the entity can be modified by any user
 @see setGloballyWritable:
 */
- (BOOL) isGloballyWritable;

/** Set global write permission for the associated object.
 
 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param writable `YES` to allow the associated object to be modified by any user.
 @see isGloballyWritable
 */
- (void) setGloballyWritable:(BOOL)writable;

@end
