//
//  KCSMetadata.h
//  KinveyKit
//
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KinveyHeaderInfo.h"

/** Fieldname to access an object's creator, using KCSQuery.
 @since 1.10.2
 */
FOUNDATION_EXPORT NSString* KCSMetadataFieldCreator;
/** Fieldname to access an object's last modified time, using KCSQuery.
 @since 1.10.2
 */
FOUNDATION_EXPORT NSString* KCSMetadataFieldLastModifiedTime;
/** Fieldname to access an object's entity creation time, using KCSQuery.
 @since 1.14.2
 */
FOUNDATION_EXPORT NSString* KCSMetadataFieldCreationTime;

/** This object represents backend information about the entity, such a timestamp and read/write permissions.
 
 To take advantage of KCSMetadata, map an entity property of this type to field `KCSEntityKeyMetadata`. The object that maps a particular instance is the "associated object." 
 */
@interface KCSMetadata : NSObject

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

/** A list of users that have explict permission to read this entity. The actual set of users that can read the entity may be greater than this list, depending on the global permissions of the associated object or the object's containing collection. 
 @return an array of user ids that have acess to read this entity
 @see setUsersWithReadAccess:
 @see isGloballyReadable
 @see readers
 @deprecatedIn 1.14.0
 */
- (NSArray*) usersWithReadAccess KCS_DEPRECATED(Use 'readers' array directly, 1.14.0);

/** Update the array of users with explicit read access. 
 
 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param readers a non-nil array of string user id's that have explicit read access to the associated object.
 @see usersWithReadAccess
 @see setGloballyReadable:
 @see readers
 @deprecatedIn 1.14.0
 */
- (void) setUsersWithReadAccess:(NSArray*) readers KCS_DEPRECATED(Use 'readers' array directly, 1.14.0);

/** A list of users that have explict permission to write this entity. The actual set of users that can write the entity may be greater than this list, depending on the global permissions of the associated object or the object's containing collection. 
 @return an array of user ids that have acess to read this entity
 @see setUsersWithWriteAccess:
 @see isGloballyWritable
 @see writers
 @deprecatedIn 1.14.0
 */
- (NSArray*) usersWithWriteAccess KCS_DEPRECATED(Use 'writers' array directly, 1.14.0);

/** Update the array of users with explicit write access. 

 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param writers a non-nil array of string user id's that have explicit write access to the associated object.
 @see usersWithWriteAccess
 @see setGloballyWritable:
 @see writers
 @deprecatedIn 1.14.0
 */
- (void) setUsersWithWriteAccess:(NSArray*) writers KCS_DEPRECATED(Use 'writers' array directly, 1.14.0);

/** The global read permission for the associated entity. This could be broader or more restrictive than its collection's permissions.
 @return `YES` if the entity can be read by any user
 @see usersWithReadAccess
 @see setGloballyReadable:
 */
- (BOOL) isGloballyReadable;

/** Set global read permission for the associated object.
 
 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param readable `YES` to allow the associated object to be read by any user.
 @see setUsersWithReadAccess:
 @see isGloballyReadable
*/
- (void) setGloballyReadable:(BOOL)readable;

/** The global write permission for the associated entity. This could be broader or more restrictive than its collection's permissions.
 @return `YES` if the entity can be modified by any user
 @see usersWithWriteAccess
 @see setGloballyWritable:
 */
- (BOOL) isGloballyWritable;

/** Set global write permission for the associated object.
 
 Any change in permissions do not take effect until the associated object is saved to the backend.
 @param writable `YES` to allow the associated object to be modified by any user.
 @see setUsersWithWriteAccess:
 @see isGloballyWritable
 */
- (void) setGloballyWritable:(BOOL)writable;

@end
