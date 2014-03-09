//
//  KCSResourceStore.h
//  KinveyKit
//
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
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

@class KCSAuthHandler;

/**
 KCSResourceStore loads, creates/updates, and deletes blob resources from the Kinvey backend
 @deprecatedIn 1.18.0
 */
@interface KCSResourceStore : NSObject <KCSStore>

@property (nonatomic, strong) KCSAuthHandler *authHandler KCS_DEPRECATED(KCSResourceStore deprecated -- use KCSFileStore API instead, 1.18.0);

///---------------------------------------------------------------------------------------
/// @name Adding/Updating
///---------------------------------------------------------------------------------------

/** Add or update an object (or objects) in the store.
 
 This is the basic method to add or update resources. 
 
 @param object A url to a file to add/update in the resources (if the object is a `NSArray`, all objects will be added/updated). The object must be a `NSURL` that points a local file, or a `NSArray` of such `NSURL` objects.
 @param completionBlock A block that gets invoked when the addition/update is "complete" (as defined by the store)
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 
 @deprecatedIn 1.18.0
 */
- (void)saveObject: (id)object withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(KCSResourceStore deprecated -- use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:]  instead, 1.18.0);


- (void)saveData:(NSData*)data toFile:(NSString*)file withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(KCSResourceStore deprecated -- use +[KCSFileStore uploadData:options:completionBlock:progressBlock:] API instead, 1.18.0);


///---------------------------------------------------------------------------------------
/// @name Querying/Fetching
///---------------------------------------------------------------------------------------

/*! Query or fetch an resource (or resource) in the store.
 
 This method takes a `NSString` filename object or `NSArray` of string filenames and fetches them from the resource store.
 
 @param query A string filename. 
 @param completionBlock A block that gets invoked when the query/fetch is "complete".
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 @deprecatedIn 1.18.0
 */
- (void)queryWithQuery: (id)query withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(KCSResourceStore deprecated -- use +[KCSFileStore downloadFileByQuery:completionBlock:progressBlock:] instead, 1.18.0);

//internal method
- (void)loadObjectWithID:(id)objectID withCompletionBlock:(KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(KCSResourceStore deprecated -- use  +[KCSFileStore downloadFile:completionBlock:progressBlock:] instead, 1.18.0);

@end
