//
//  KCSAppdataStore.h
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
#import "KCSStore.h"
#import "KCSBackgroundAppdataStore.h"

@class KCSCollection;

/**
 KCSStore options dictionary key for the backing resource
 */
#define KCSStoreKeyResource @"resource"

/**
 KCSStore options dictionary key for the backing collection name. This can be used instead of suppling a KCSStoreKeyResource. Use with KCSStoreKeyCollectionTemplateClass.
 
 @since 1.11.0
 */
#define KCSStoreKeyCollectionName @"collectionName"

/**
 KCSStore options dictionary key for the backing collection object class.  This can be used instead of suppling a KCSStoreKeyResource. Use with KCSStoreKeyCollectionName. If a KCSStoreKeyCollectionName is supplied, but no KCSStoreKeyCollectionTemplateClass, NSMutableDictionary will be used by default.
 
 @since 1.11.0
 */
#define KCSStoreKeyCollectionTemplateClass @"collectionClass"

//internal key
#define KCSStoreKeyOngoingProgress @"referenceprogress"
#define KCSStoreKeyTitle @"storetitle"

/**
 Basic Store for loading Application Data from a Collection in the Kinvey backend. 
 
 The preferred use of this class is to use a KCSCachedStore with a `cachePolicy` of `KCSCachePolicyNone`.
 
 @see KCSCachedStore
 */
@interface KCSAppdataStore : KCSBackgroundAppdataStore

@property (nonatomic, strong) KCSAuthHandler *authHandler KCS_DEPRECATED(Auth handler not used, 1.22.0);


/** Initialize an empty store with the given collections, options and the default authentication
 
 This will initialize an empty store with the given options and default authentication,
 the given options dictionary should be defined by the Kinvey Store that implements
 the protocol.
 
 @param collection the Kinvey backend Collection providing data to this store.
 @param options A dictionary of options to configure the store. (Can be nil if there are no options)
 @see [KCSStore storeWithOptions:]
 @return An autoreleased empty store with configured options and default authentication. 
 */
+ (instancetype) storeWithCollection:(KCSCollection*)collection options:(NSDictionary*)options;

/** Initialize an empty store with the given options and the given authentication
 
 This will initialize an empty store with the given options and given authentication,
 the options dictionary should be defined by the Kinvey Store that implements
 the protocol.  Authentication is Kinvey Store specific, refer to specific store's
 documentation for details.
 
 @param collection the Kinvey backend Collection providing data to this store.
 @param options A dictionary of options to configure the store. (Can be nil if there are no options)
 @param authHandler The Kinvey Authentication Handler used to authenticate backend requests.
 
 @return An autoreleased empty store with configured options and given authentication.
 @depcratedIn 1.22.0
 @deprecated Use use storeWithCollection:options: instead
 */
+ (instancetype)storeWithCollection:(KCSCollection*)collection authHandler:(KCSAuthHandler *)authHandler withOptions: (NSDictionary *)options KCS_DEPRECATED(Auth handler not used--use storeWithCollection:options: instead, 1.22.0);

///---------------------------------------------------------------------------------------
/// @name Querying/Fetching
///---------------------------------------------------------------------------------------

/** Load objects from the store with the given IDs.
 
 @param objectID this is an individual ID or an array of IDs to load
 @param completionBlock A block that gets invoked when all objects are loaded
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 */
- (void)loadObjectWithID: (id)objectID 
     withCompletionBlock: (KCSCompletionBlock)completionBlock
       withProgressBlock: (KCSProgressBlock)progressBlock;

/*! Aggregate objects in the store and apply a function to all members in that group.
 
 This method will find the objects in the store, collect them with other other objects that have the same value for the specified fields, and then apply the supplied function on those objects. Right now the types of functions that can be applied are simple mathematical operations. See KCSReduceFunction for more information on the types of functions available.
 
 @param fieldOrFields The array of fields to group by (or a single `NSString` field name). If multiple field names are supplied the groups will be made from objects that form the intersection of the field values. For instance, if you have two fields "a" and "b", and objects "{a:1,b:1},{a:1,b:1},{a:1,b:2},{a:2,b:2}" and apply the `COUNT` function, the returned KCSGroup object will have an array of 3 objects: "{a:1,b:1,count:2},{a:1,b:2,count:1},{a:2,b:2,count:1}". For objects that don't have a value for a given field, the value used will be `NSNull`.
 @param function This is the function that is applied to the items in the group. If you do not want to apply a function, just use queryWithQuery:withCompletionBlock:withProgressBlock: instead and query for items that match specific field values.
 @param completionBlock A block that is invoked when the grouping is complete, or an error occurs. 
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @see group:reduce:condition:completionBlock:progressBlock:
 @see KCSGroup
 @see KCSReduceFunction
 */
- (void)group:(id)fieldOrFields reduce:(KCSReduceFunction*)function completionBlock:(KCSGroupCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/*! Aggregate objects in the store and apply a function to all members in that group that satisfy the condition.
 
 This method will find the objects in the store, collect them with other other objects that have the same value for the specified fields, and then apply the supplied function on those objects. Right now the types of functions that can be applied are simple mathematical operations. See KCSReduceFunction for more information on the types of functions available.
 
 @param fieldOrFields The array of fields to group by (or a single `NSString` field name). If multiple field names are supplied the groups will be made from objects that form the intersection of the field values. For instance, if you have two fields "a" and "b", and objects "{a:1,b:1},{a:1,b:1},{a:1,b:2},{a:2,b:2}" and apply the `COUNT` function, the returned KCSGroup object will have an array of 3 objects: "{a:1,b:1,count:2},{a:1,b:2,count:1},{a:2,b:2,count:1}". For objects that don't have a value for a given field, the value used will be `NSNull`.
 @param function This is the function that is applied to the items in the group. If you do not want to apply a function, just use queryWithQuery:withCompletionBlock:withProgressBlock: instead and query for items that match specific field values.
 @param condition This is a KCSQuery object that is used to filter the objects before grouping. Only groupings with at least one object that matches the condition will appear in the resultant KCSGroup object. __The group function does not support sorting, limit, or skip modifiers__. 
 @param completionBlock A block that is invoked when the grouping is complete, or an error occurs. 
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @see group:reduce:completionBlock:progressBlock:
 @see KCSGroup
 @see KCSReduceFunction
 */
- (void) group:(id)fieldOrFields reduce:(KCSReduceFunction*)function condition:(KCSQuery*)condition completionBlock:(KCSGroupCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;


#pragma mark -  Information
/** Count all the elements the collection
  
 @param countBlock the block that receives the response 
 @see countWithQuery:completion:
 */
- (void)countWithBlock: (KCSCountBlock)countBlock;

/** Count all the elements the collection that match a given query.
 
 This method is useful for finding out how big a query will be without transferring all the data. This method is __not__ cached. 
 
 @param query the query to filter the elements
 @param countBlock the block that receives the response
 @since 1.15.0
 */
- (void)countWithQuery:(KCSQuery*)query completion:(KCSCountBlock)countBlock;
@end
