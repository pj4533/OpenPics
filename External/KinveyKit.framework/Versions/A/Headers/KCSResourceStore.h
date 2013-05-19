//
//  KCSResourceStore.h
//  KinveyKit
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>

#import "KCSStore.h"

@class KCSAuthHandler;

/**
 KCSResourceStore loads, creates/updates, and deletes blob resources from the Kinvey backend
 */
@interface KCSResourceStore : NSObject <KCSStore>

@property (nonatomic, strong) KCSAuthHandler *authHandler;

///---------------------------------------------------------------------------------------
/// @name Adding/Updating
///---------------------------------------------------------------------------------------

/** Add or update an object (or objects) in the store.
 
 This is the basic method to add or update resources. 
 
 @param object A url to a file to add/update in the resources (if the object is a `NSArray`, all objects will be added/updated). The object must be a `NSURL` that points a local file, or a `NSArray` of such `NSURL` objects.
 @param completionBlock A block that gets invoked when the addition/update is "complete" (as defined by the store)
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 
 */
- (void)saveObject: (id)object withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock;


- (void)saveData:(NSData*)data toFile:(NSString*)file withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock;


///---------------------------------------------------------------------------------------
/// @name Querying/Fetching
///---------------------------------------------------------------------------------------

/*! Query or fetch an resource (or resource) in the store.
 
 This method takes a `NSString` filename object or `NSArray` of string filenames and fetches them from the resource store.
 
 @param query A string filename. 
 @param completionBlock A block that gets invoked when the query/fetch is "complete".
 @param progressBlock A block that is invoked whenever the store can offer an update on the progress of the operation.
 */
- (void)queryWithQuery: (id)query withCompletionBlock: (KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock;

//internal method
- (void)loadObjectWithID:(id)objectID withCompletionBlock:(KCSCompletionBlock)completionBlock withProgressBlock: (KCSProgressBlock)progressBlock;

@end
