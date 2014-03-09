//
//  KinveyCollection.h
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
#import "KinveyPersistable.h"
#import "KCSBlockDefs.h"
#import "KinveyHeaderInfo.h"

/** The name of the special case user collection
 @since 1.10.2
 */
KCS_CONSTANT KCSUserCollectionName;


/*!  Describes required methods for requesting entities from the Kinvey Service.
 *
 * This Protocol should be implemented by a client for processing the results of a Entity request against the KCS
 * service that deals with a collection of Entities.
 */
KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0)
@protocol KCSCollectionDelegate <NSObject>

///---------------------------------------------------------------------------------------
/// @name Failure
///---------------------------------------------------------------------------------------

/*! Called when a request fails for some reason (including network failure, internal server failure, request issues...)
 * 
 * Use this method to handle failures.
 *  @param collection The collection attempting to perform the operation.
 *  @param error An object that encodes our error message 
 */
- (void) collection: (KCSCollection *)collection didFailWithError: (NSError *)error KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

///---------------------------------------------------------------------------------------
/// @name Success
///---------------------------------------------------------------------------------------

/*! Called when a request completes successfully.
 * @param collection The collection attempting to perform the operation.
 * @param result An NSArray of Class objectTemplate objects. 
 *
 */
- (void) collection: (KCSCollection *)collection didCompleteWithResult: (NSArray *)result KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

@end





/*! Used to document methods required for handling simple integer opertions completing. */
KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0)
@protocol KCSInformationDelegate <NSObject>
///---------------------------------------------------------------------------------------
/// @name Failure
///---------------------------------------------------------------------------------------

/*! Called when the operation encounters an error (either through completion with failure or lack of completion).

 @param collection The collection attempting to perform the operation. 
 @param error The error that the system encountered.

 */
- (void) collection: (KCSCollection *)collection informationOperationFailedWithError: (NSError *)error KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

///---------------------------------------------------------------------------------------
/// @name Success
///---------------------------------------------------------------------------------------

/*! Called when the operation complets with no failures

 @param collection The collection attempting to perform the operation.
 @param result The integer result.

 */
- (void) collection: (KCSCollection *)collection informationOperationDidCompleteWithResult: (int)result KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

@end


@class KCSQuery;
/*! Object for managing a collection of KinveyEntities
*
*/
@interface KCSCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Getting information about this collection object
///---------------------------------------------------------------------------------------

/*! String representation of the name of the Kinvey Collection. */
@property (strong) NSString *collectionName;

/*! An instance of an object stored by this collection */
@property (strong) Class objectTemplate;

/*! A cached copy of the last results from Kinvey (handy if you forget to copy them in your delegate) */
@property (strong) NSArray *lastFetchResults KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

/*! The Endpoint where we look for a request */
@property (nonatomic, strong, readonly) NSString *baseURL;



///---------------------------------------------------------------------------------------
/// @name Creating Access to a Kinvey Object
///---------------------------------------------------------------------------------------
/*! Return a representation of a Kinvey Collection
 
 This collection can be used to manage all items in this collection on the Kinvey service.
 
 @param string Name of the Collection (the name you'll see in the Kinvey Console) we're accessing
 @param templateClass The Class of objects that we're storing.  Instances of this class will be returned

 @return The collection object representing the back-end collection.

 */
+ (instancetype) collectionFromString: (NSString *)string ofClass: (Class)templateClass;


/** The special user collection
 @return a Collection that can be used to query `KCSUser` objects.
 @since 1.10.2
 */
+ (instancetype) userCollection;

///---------------------------------------------------------------------------------------
/// @name Fetching Entities from Kinvey
///---------------------------------------------------------------------------------------
/*! Fetch all of the entities in the collection
 *  @param delegate The delegate that we'll notify upon completion of the request.
 */
- (void)fetchAllWithDelegate: (id <KCSCollectionDelegate>)delegate KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

/*! Fetch all of the entites that match the query instance variable.
 *  
 *  NOTE: If `collection.query == nil` then this method will return an error status, use
 *  fetchWithDelegate: instead.
 *
 *  NOTE: The filter interface has been removed in version 1.14 of KinveyKit. 
 *  @param delegate The delegate that we'll notify upon completion of the request.
 */
- (void)fetchWithDelegate: (id <KCSCollectionDelegate>)delegate KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

// Undocumented
- (void)fetchWithQuery: (KCSQuery *)query withCompletionBlock: (KCSCompletionBlock)onCompletion withProgressBlock: (KCSProgressBlock)onProgress KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

///---------------------------------------------------------------------------------------
/// @name Building Queries
///---------------------------------------------------------------------------------------

/*! The current query for this collection.  Overwrite to assign new query.
    NOTE: if query is `nil` and fetchWithDelegate: is called, an error status will be returned. */
@property (nonatomic, strong) KCSQuery *query KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

///---------------------------------------------------------------------------------------
/// @name Obtaining information about a Collection
///---------------------------------------------------------------------------------------
/* Find the total number of elements in a collection
 
 @param delegate The delegate to inform that the operation is complete.
 */
- (void)entityCountWithDelegate: (id <KCSInformationDelegate>)delegate KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);
- (void)entityCountWithBlock: (KCSCountBlock)countBlock KCS_DEPRECATED(Use KCSAppdataStore API instead, 1.26.0);

@end
