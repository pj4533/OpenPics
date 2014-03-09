//
//  KCSCachedStore.h
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
#import "KCSAppdataStore.h"

/** Cache Policies. These constants determine the caching behavior when used with KCSChacedStore query. */
typedef enum KCSCachePolicy {
    /** No Caching - all queries are sent to the server */
    KCSCachePolicyNone,
    KCSCachePolicyLocalOnly,
    KCSCachePolicyLocalFirst,
    KCSCachePolicyNetworkFirst,
    KCSCachePolicyBoth,
    KCSCachePolicyReadOnceAndSaveLocal_Xperimental //for caching assests that change infrequently (e.g. ui assets, names of presidents, etc)
} KCSCachePolicy;

#define KCSStoreKeyCachePolicy @"cachePolicy"

/** Enable retrying saves/deletes when app comes back online with `@(YES)`.
 */
KCS_CONSTANT KCSStoreKeyOfflineUpdateEnabled;

//internal use
#define KCSStoreKeyLocalCacheTimeout @"localcache.timeout"


/**
 This application data store caches queries, depending on the policy.
 
 Available caching policies:
 
 - `KCSCachePolicyNone` - No caching, all queries are sent to the server.
 - `KCSCachePolicyLocalOnly` - Only the cache is queried, the server is never called. If a result is not in the cache, an error is returned.
 - `KCSCachePolicyLocalFirst` - The cache is queried and if the result is stored, the `completionBlock` is called with that value. The cache is then updated in the background. If the cache does not contain a result for the query, then the server is queried first.
 - `KCSCachePolicyNetworkFirst` - The network is queried and the cache is updated with each result. The cached value is only returned when the network is unavailable. 
 - `KCSCachePolicyBoth` - If available, the cached value is returned to `completionBlock`. The network is then queried and cache updated, afterwards. The `completionBlock` will be called again with the updated result from the server.
 
 For an individual store, the cache policy can inherit from the defaultCachePolicy, be set using storeWithOptions: factory constructor, supplying the enum for the key `KCSStoreKeyCahcePolicy`.
 
 This store also provides offline save semantics. To enable offline save, supply a unique string for this store for the `KCSStoreKeyUniqueOfflineSaveIdentifier` key in the options dictionary passed in class factory method ([KCSAppdataStore storeWithCollection:options:]. You can also supply an optional `KCSStoreKeyOfflineSaveDelegate` to intercept or be notified when those saves happen when the application becomes online. 
 
 If offline save is enabled, and the application is offline when the `saveObject:withCompletionBlock:withProgressBlock` method processes the saves, the completionBlock will be called with a networking error, but the saves will be queued to be saved when the application becomes online. This completion block will _not_ be called when those queued saves are processed. Instead, the the offline save delegate will be called. The completion block `errorOrNil` object will have in addition to the error information, an array in its `userInfo` for the `KCS_ERROR_UNSAVED_OBJECT_IDS_KEY` containing the `_id`s of the unsaved objects. If the objects haven't been assigned an `_id` yet, the value will be a `NSNull`, in order to keep the array count reliable. 
 
 For more information about offline saving, see KCSOfflineSaveStore and our iOS developer's user guide at docs.kinvey.com. 
 */
@interface KCSCachedStore : KCSAppdataStore
/** @name Cache Policy */

/** The cache policy used, by default, for this store */
@property (nonatomic, readwrite) KCSCachePolicy cachePolicy;

#pragma mark - Default Cache Policy
/** gets the default cache policy for all new KCSCachedStore's */
+ (KCSCachePolicy) defaultCachePolicy;
/** Sets the default cache policy for all new KCSCachedStore's.
 @param cachePolicy the default `KCSCachePolicy` for all new stores.
 */
+ (void) setDefaultCachePolicy:(KCSCachePolicy)cachePolicy;

/** @name Querying/Fetching */

/**  Load objects from the store with the given IDs (optional cache policy).
 
 @param objectID this is an individual ID or an array of IDs to load
 @param completionBlock A block that gets invoked when all objects are loaded
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @param cachePolicy override the object's cachePolicy for this load only.
 @see [KCSAppdataStore loadObjectWithID:withCompletionBlock:withProgressBlock:]
 */
- (void)loadObjectWithID:(id)objectID 
     withCompletionBlock:(KCSCompletionBlock)completionBlock
       withProgressBlock:(KCSProgressBlock)progressBlock
             cachePolicy:(KCSCachePolicy)cachePolicy;

/** Query or fetch an object (or objects) in the store (optional cache policy).
 
 This method takes a query object and returns the value from the server or cache, depending on the supplied `cachePolicy`. 
 
 This method might be used when you know the network is unavailable and you want to use `KCSCachePolicyLocalOnly` until the network connection is reestablished, and then go back to using the store's normal policy.
 
 @param query A query to act on a store.  The store defines the type of queries it accepts, an object of type `[KCSQuery query]` causes all objects to be returned.
 @param completionBlock A block that gets invoked when the query/fetch is "complete" (as defined by the store)
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @param cachePolicy the policy for to use for this query only. 
 */
- (void)queryWithQuery:(id)query withCompletionBlock:(KCSCompletionBlock)completionBlock withProgressBlock:(KCSProgressBlock)progressBlock cachePolicy:(KCSCachePolicy)cachePolicy;

/*! Aggregate objects in the store and apply a function to all members in that group (optional cache policy).
 
 This method will find the objects in the store, collect them with other other objects that have the same value for the specified fields, and then apply the supplied function on those objects. Right now the types of functions that can be applied are simple mathematical operations. See KCSReduceFunction for more information on the types of functions available.
 
 @param fieldOrFields The array of fields to group by (or a single `NSString` field name). If multiple field names are supplied the groups will be made from objects that form the intersection of the field values. For instance, if you have two fields "a" and "b", and objects "{a:1,b:1},{a:1,b:1},{a:1,b:2},{a:2,b:2}" and apply the `COUNT` function, the returned KCSGroup object will have an array of 3 objects: "{a:1,b:1,count:2},{a:1,b:2,count:1},{a:2,b:2,count:1}". For objects that don't have a value for a given field, the value used will be `NSNull`.
 @param function This is the function that is applied to the items in the group. If you do not want to apply a function, just use queryWithQuery:withCompletionBlock:withProgressBlock: instead and query for items that match specific field values.
 @param condition This is a KCSQuery object that is used to filter the objects before grouping. Only groupings with at least one object that matches the condition will appear in the resultant KCSGroup object. 
 @param completionBlock A block that is invoked when the grouping is complete, or an error occurs. 
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @param cachePolicy override the object's cachePolicy for this group query only.
 @see [KCSAppdataStore group:reduce:condition:completionBlock:progressBlock:]
 */
- (void)group:(id)fieldOrFields reduce:(KCSReduceFunction *)function condition:(KCSQuery *)condition completionBlock:(KCSGroupCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock cachePolicy:(KCSCachePolicy)cachePolicy;

///---------------------------------------------------------------------------------------
/// @name Bulk Data Operations
///---------------------------------------------------------------------------------------

/** Seed the store's cache with entities
 @param jsonObjects an array of `NSDictionary` objects to place into the store's cache. These must have at least an `_id` field set.
 @see exportCache
 @since 1.24.0
 */
- (void) import:(NSArray*)jsonObjects;

/** Export the cache as an array of entities ready for serialization.
 
 @return an array of the entity data
 @see import:
 @since 1.24.0
 */
- (NSArray*) exportCache;

/** Clears the data caches.
 
 @since 1.24.0
 */
+ (void) clearCaches;

@end
