//
//  KCSOfflineUpdateDelegate.h
//  KinveyKit
//
//  Copyright (c) 2013 Kinvey. All rights reserved.
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
 The `KCSClient` object can have single delegate for all data stores that implements this protocol. In order to participate in offline updates, there must be a global offline delegate, and each instance of `KCSCachedStore` or `KCSLinkedAppdataStore` must also have the option `KCSStoreKeyOfflineUpdateEnabled` set to YES.
 
     id<KCSOfflineUpdateDelegate> myDelegate = [[ImplementingClass alloc] init];
     [[KCSClient sharedClient] setOfflineDelegate:myDelegate];
 
 NOTE that these delegate method can be called on an arbitray thread. Use dispatch queues to make sure all UI updates are handled on the main thread.
 
 @since 1.23.0
 */
@protocol KCSOfflineUpdateDelegate <NSObject>

@optional

///---------------------------------------------------------------------------------------
/// @name Enqueuing items
///---------------------------------------------------------------------------------------

/** Called when an object is enqueued to be later saved or removed.
 
 @param objectId The `KCSEntityKeyId` of the object to be saved or deleted. If the delete is a query then this will be the query string.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @since 1.23.0
 */
- (void) didEnqueueObject:(NSString*)objectId inCollection:(NSString*)collectionName;

/** Called before an object is enqueued to be later saved or removed. This allows you to prevent a request from being retried later.
 
 @param objectId The `KCSEntityKeyId` of the object to be saved or deleted. If the delete is a query then this will be the query string.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @param error is the error that occurred during the last attempt to send the request, causing the retry to be queued.
 @return YES if the request should be retried when the app regains connectivity
 @since 1.23.0
 */
- (BOOL) shouldEnqueueObject:(NSString*)objectId inCollection:(NSString*)collectionName onError:(NSError*)error;


///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------

/** Called before a queued object is saved. This method allows the client to expire old saves or otherwise control if the save should be attempted.
 
 @param objectId The `KCSEntityKeyId` of the object to be saved.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @param saveTime the last time the save was attempted. If multiple offline failures occur this will not be the original save time.
 @return YES if a save request should be sent
 @since 1.23.0
 */
- (BOOL) shouldSaveObject:(NSString*)objectId inCollection:(NSString*)collectionName lastAttemptedSaveTime:(NSDate*)saveTime;

/** Called before a save request is sent.
 
 @param objectId The `KCSEntityKeyId` of the object to be saved.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @since 1.23.0
 */
- (void) willSaveObject:(NSString*)objectId inCollection:(NSString*)collectionName;

/** Called after a save request is successful. 
 
 @param objectId The `KCSEntityKeyId` of the object saved.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @since 1.23.0
 */
- (void) didSaveObject:(NSString*)objectId inCollection:(NSString*)collectionName;


///---------------------------------------------------------------------------------------
/// @name Deleting
///---------------------------------------------------------------------------------------

/** Called before a queued object is delete. This method allows the client to expire old delete requests or otherwise control if the delete should be attempted.
 
 @param objectId The `KCSEntityKeyId` of the object to be removed.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @param time the last time the delete was attempted. If multiple offline failures occur this will not be the original deletion time.
 @return YES if a delete request should be sent
 @since 1.23.0
 */
- (BOOL) shouldDeleteObject:(NSString*)objectId inCollection:(NSString*)collectionName lastAttemptedDeleteTime:(NSDate*)time;

/** Called before a delete request is sent.
 
 @param objectId The `KCSEntityKeyId` of the object to be removed.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @since 1.23.0
 */
- (void) willDeleteObject:(NSString*)objectId inCollection:(NSString*)collectionName;

/** Called after a delete request is successful.
 
 @param objectId The `KCSEntityKeyId` of the object removed.
 @param collectionName The name of the collection. For special collections such as file store or users, use the constants `KCSUserCollectionName` and `KCSFileStoreCollectionName`.
 @since 1.23.0
 */
- (void) didDeleteObject:(NSString*)objectId inCollection:(NSString*)collectionName;


@end
