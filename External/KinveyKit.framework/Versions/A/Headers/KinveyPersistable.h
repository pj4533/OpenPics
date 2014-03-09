//
//  KinveyPersistable.h
//  KinveyKit
//
//  Copyright (c) 2008-2014, Kinvey, Inc. All rights reserved.
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

// Forward declaration to have access to the KCSClient definition in this protocol definition.
@class KCSCollection;

/** Defines the implementation details of a class expecting to perform actions after the completion of a save operation.

Developers interested in performing actions based on the state of a save operation should conform to this protocol.

 @deprecated Use KCSAppdataStore methods instead
 @depreatedIn 1.26.1
 */
KCS_DEPRECATED(Use KCSAppdataStore methods instead, 1.26.1)
@protocol KCSPersistableDelegate <NSObject>

/** Invoked when a save operation fails
 @param entity The Object that was attempting to be saved.
 @param error A detailed description of the error.
 
 @deprecated Use KCSAppdataStore methods instead
 @depreatedIn 1.26.1
 */
- (void) entity: (id)entity operationDidFailWithError: (NSError *)error KCS_DEPRECATED(Use KCSAppdataStore methods instead, 1.26.1);

/** Invoked when a save operation completes successfully.
 @param entity The Object that was attempting to be saved.
 @param result The result of the operation (NOTE: The value of this result is still changing, do not count on the value yet)
 
 @deprecated Use KCSAppdataStore methods instead
 @depreatedIn 1.26.1
 */
- (void) entity:(id)entity operationDidCompleteWithResult: (NSObject *)result KCS_DEPRECATED(Use KCSAppdataStore methods instead, 1.26.1);

@end

/** Definies the interface for a persistable object.

This protocol is used to inform that this object is able to be saved to the Kinvey Cloud Service.  The methods
defined in this protocol are used to determine what data to save and then to actually save the data.

The KCSEntity category on NSObject conforms to this protocol, providing a default implementation of this protocol
for all NSObject descendants.  You may directly implement this protocol in order to provide actions not accomplished by
the default methods provided.  See method documentation for important information about restrictions on clients when
implementing these methods.
 
 @bug Only the mapping and advanced should be implemented by the library user, the implementation provided by the KCSEntity category
 should be used for all other methods.
 
 */
@protocol KCSPersistable <NSObject>
#pragma mark - Mapping Methods
/* Kinvey backend key for an entity's unique id */
#define KCSEntityKeyId @"_id"
/* Kinvey backend key for metadata information */
#define KCSEntityKeyMetadata @"_kinveymeta"
/* Kinvey backend key for geolocation information. This is a free field for doing geo-queries */
#define KCSEntityKeyGeolocation @"_geoloc"

///---------------------------------------------------------------------------------------
/// @name Map from Local to Kinvey property names
///---------------------------------------------------------------------------------------

/** Provide the mapping from an Entity's representation to the Native Objective-C representation.

 
 A simple implementation of a mapping function is:

 Header file:
    @property (retain, readonly) NSDictionary *mapping;

 Implimentation File:
        @synthesize mapping;

        - (id)init
        {
            self = [super init];
            if (self){
                mapping = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"EntityProperty1", @"InstanceVariableName1",
                    @"EntityProperty2", @"InstanceVariableName2", nil];

            }
        }
        - (NSDictionary *)propertyToElementMapping
        {
            return mapping;
        }

 
 
 @bug In this version of KCS this method has no default implementation and will raise an exception if the default
 implementation is used.

 @return The dictionary that maps from objective-c to Kinvey (JSON) mapping.

 */
- (NSDictionary*)hostToKinveyPropertyMapping;


@optional
/** Provide the mapping from an Entity's represenation to their related collections. 
 
 Implementing this method allows an object to be saved and loaded, perserving its relations to other entities. The keys are the field names on the _Kinvey_ side, and values is the name of the Kinvey collection where that related data resides.
 
 The actual value stored in backend will be a `KinveyRef` dictionary that stores the related object's `_id` and collection name. When loading the entity where this method is not implemented and not going through a KCSLinkedAppdataStore, the value will be a NSDictionary with the KinveyRef value, and not the associated object.
 
 Binary data (UIImage, NSData, etc) can also be referenced in properties. This is done by mapping those properties to the collection name: `KCSFileStoreCollectionName`.
 
 Use this method with kinveyObjectBuilderOptions `KCS_REFERENCE_MAP_KEY` to specify object types.
 
 See the online Kinvey documentation for more information.
 @see kinveyObjectBuilderOptions
 @return a dictionary mapping Kinvey entity fields to collections.
 @since 1.8
 */
+ (NSDictionary*) kinveyPropertyToCollectionMapping;

/** Provide a list of backend reference objects to save when this object is saved through a `KCSLinkedAppdataStore`. 
 
 Properties thus listed will have their objects saved to their collections when this object is saved. Any reference properties (specified in `kinveyPropertyToCollectionMapping`) not listed in return array will still have the references created and saved; only the save will not be recusive to the reference object. Queries/Loads will still create the reference objects. 
 
 @return an array of backend property names to save
 @see kinveyPropertyToCollectionMapping
 @since 1.10.3
 */
- (NSArray*) referenceKinveyPropertiesOfObjectsToSave;


#define KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY @"KCS_DESIGNATED_INITIALIZER_MAPPING_KEY"
#define KCS_USE_DICTIONARY_KEY @"KCS_DICTIONARY_MAPPER_KEY"
#define KCS_DICTIONARY_NAME_KEY @"KCS_DICTIONARY_NAME_KEY"
#define KCS_DICTIONARY_DATATYPE_BUILDER @"KCS_DICTIONARY_DATATYPE_BUILDER"
#define KCS_REFERENCE_MAP_KEY @"KinveyObjectBuilder_REFERENCE_MAP_KEY"
#define KCS_IS_DYNAMIC_ENTITY @"KinveyObjectBuilder_IsDynamic"


///---------------------------------------------------------------------------------------
/// @name Advanced Options (Here Be Dragons!)
///---------------------------------------------------------------------------------------

/** Returns an NSDictionary that details advanced object building options.
 
 Most users of Kinvey will not need to use this feature.  Please be careful.
 
 Options recognized:
 - KCS_USE_DESIGNATED_INITIALIZER_MAPPING_KEY -- If set to YES, KinveyKit will build your objects via: kinveyObjectBuilderOptions
 - KCS_USE_DICTIONARY_KEY -- If set Kinvey will use a a dictionary to map data to Kinvey
 - KCS_DICTIONARY_NAME_KEY -- The name of the Instance Variable that is the dictionary to map.
 - KCS_REFERENCE_MAP_KEY -- A dictionary mapping object properties to class objects, for use with relational data. 
 
 If KCS_USE_DICTIONARY_KEY is set to an NSNumber representing YES then KinveyKit will look for at the value for KCS_DICTIONARY_NAME_KEY.
 It will then look in your object for a property whos name is this value and is of type NSDictionary.  It will store all Key-Value pairs
 in this dictionary to the collection on the backend as individual properties (eg, the dictionary is not stored, but the key-values end
 up stored as property-values in Kinvey).  When fetching from Kinvey any properties that are not in the mapping function are placed
 as key-values into this dictionary.
 
 The KCS_REFERENCE_MAP_KEY NSDictionary should map the object properties to the class objects that will be used to build them when loaded from the back-end. Properties not specified will be inferred from the class definition, so this dictionary is only needed to substitute the property type (e.g. to use `MyObject` instead of `id` or `NSObject`) or when the type is a collection, such as `NSArray` or `NSSet`. This is only used when loading related objects through a KCSLinkedAppdataStore, and where those properties have been specified in kinveyPropertyToCollectionMapping.
 
 For example, 
      Header file (Person.h)
        @interface Person : NSObject <KCSPersistable>
            @property NSArray* children;
            @property id mother;
            @property Person* father
        @end
      
      Implementation (Person.m)
        + (NSDictionary*) kinveyPropertyToCollectionMapping
        {
        return @{ @"children" : @"PeopleCollection", @"mother" : @"PeopleCollection", @"father" : @"PeopleCollection"};
        }
 
        + (NSDictionary *)kinveyObjectBuilderOptions
        {
        return @{KCS_REFERENCE_MAP_KEY : @{@"children" : [Person class], @"mother" : [Person class]}}; //property father does not need to specified, since it defined as a Person
        }
            

 @return A dictionary that stores a subset of the above options that KinveyKit will use to determine advanced options.
 
 */
+ (NSDictionary *)kinveyObjectBuilderOptions;

/** Override the initializer that KinveyKit uses to build objects of this type
 
 If specified in the kinveyObjectBuilderOptions dictionary, this method will be
 called to build objects instead of `[[[self class] alloc] init]`.  This method
 _must_ return an instantiated object of the class that implements this protocol.
 This routine does not release the generated object.
 
 @updatedIn 1.17.3
 @param jsonDocument the raw server object. This can be used to fetch an existing object instead of creating a brand new one. E.g. use `jsonDocument[KCSEntityKeyId]` to get the object id and search using a `NSFetchedRequest` to find an existing NSManagedObject in the context.
 @return An instantiated object of the class implementing this protocol
 */
+ (id)kinveyDesignatedInitializer:(NSDictionary*)jsonDocument;

#pragma mark - Don't Override these methods
///---------------------------------------------------------------------------------------
/// @name Save Items
///---------------------------------------------------------------------------------------

/**  Save an Entity into KCS for a given KCS client and register a delegate to notify when complete.
 
 When overriding this method an implementer will most likely need to communicate with the KCSClient class,
 which has a different delegate interface.  An implementer will need to map between these delegates.  This does
 not apply to using the built-in implementation.
 
 @warning It is strongly advised to not override this method.
 
 @param collection An instance of a KCS collection to use in saving this Entity
 @param delegate The delegate to inform upon the completion of the save operation.
 
 @deprecated Use KCSAppdataStore methods instead
 @depreatedIn 1.26.1
 */
- (void)saveToCollection: (KCSCollection *)collection withDelegate: (id <KCSPersistableDelegate>)delegate KCS_DEPRECATED(Use KCSAppdataStore methods instead, 1.26.1);

///---------------------------------------------------------------------------------------
/// @name Delete Items
///---------------------------------------------------------------------------------------

/** Delete an entity from Kinvey and register a delegate for notification.
 When overriding this method an implementer will most likely need to communicate with the KCSClient class,
 which has a different delegate interface.  An implementer will need to map between these delegates.  This does
 not apply to using the built-in implementation.
 
 @warning It is strongly advised to not override this method.
 
 @param delegate The delegate to inform upon the completion of the delet operation.
 @param collection The collection to remove the item from.
 
 @deprecated Use KCSAppdataStore methods instead
 @depreatedIn 1.26.1
 */

- (void)deleteFromCollection: (KCSCollection *)collection withDelegate: (id<KCSPersistableDelegate>)delegate KCS_DEPRECATED(Use KCSAppdataStore methods instead, 1.26.1);

@end
