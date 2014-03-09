//
//  KCSBlobService.h
//  KinveyKit
//
//  Copyright (c) 2008-2013, Kinvey, Inc. All rights reserved.
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
#import "KCSBlockDefs.h"
#import "KinveyHeaderInfo.h"

@class KCSClient;

/*! Container for Resource responses.
 
 This represents the results from a Resource request.  Because the resource may be eventually fetched from another sericve that doesn't respond
 in the same fashion as Kinvey, we have a slightly different response format for Resources than for other Kinvey items.
 
 @deprecatedIn 1.18.0
*/
@interface KCSResourceResponse : NSObject

///---------------------------------------------------------------------------------------
/// @name Resource Information
///---------------------------------------------------------------------------------------

/*! Contains the local filename that the Resource was saved to. */
@property (nonatomic, copy, readonly) NSString *localFileName KCS_DEPRECATED(the new KCSFileStore API returns this as: -[KCSFile localURL], 1.18.0);

/*! Contains the streaming URL if it was requested. */
@property (nonatomic, copy, readonly) NSString *streamingURL KCS_DEPRECATED(the new KCSFileStore API returns this as: -[KCSFile remoteURL], 1.18.0);

/*! Contains the Resource ID, which is used to uniquely identify this resource .*/
@property (nonatomic, copy, readonly) NSString *resourceId KCS_DEPRECATED(the new KCSFileStore API returns this as: -[KCSFile fileId], 1.18.0);

 /*! Contains the actual data for the resources. */
@property (nonatomic, strong, readonly) NSData *resource KCS_DEPRECATED(the new KCSFileStore API returns this as: -[KCSFile data], 1.18.0);

/*! Contains the "expected" size of the resource. */
@property (readonly) NSInteger length KCS_DEPRECATED(the new KCSFileStore API returns this as: -[KCSFile length], 1.18.0);


@end

/*! Methods used to communicate the successful/failure of a Resource action to/from Kinvey.
 
 A client conforming to this protocol can be notified about successful or unsuccessful completion of a resource request to Kinvey.
 */
@protocol KCSResourceDelegate <NSObject> 

///---------------------------------------------------------------------------------------
/// @name Success
///---------------------------------------------------------------------------------------

/*! A successful request to Kinvey occurred with a specific result.
 
 This method will be called if the requested action completed with a successful result.
 
 @param result All information availble about the request.  See KCSResourceResponse for details of the available properties.
 */
- (void)resourceServiceDidCompleteWithResult: (KCSResourceResponse *)result;

///---------------------------------------------------------------------------------------
/// @name Failure
///---------------------------------------------------------------------------------------

/*! A failed request to Kinvey occurred.
 
 This method will be called if the requested action failed.  Note, the request action was not performed, and Kinvey remains in the
 state previous to the request.
 
 @param error An NSError that describes all availble failure information.
 
 */
- (void)resourceServiceDidFailWithError: (NSError *)error;

@end

/** Kinvey File Service wrapper
 
 This class is used to provide access to all Kinvey file services.
 */
@interface KCSResourceService : NSObject

///---------------------------------------------------------------------------------------
/// @name Downloading Resources
///---------------------------------------------------------------------------------------

+ (void)downloadResource: (NSString *)resourceId withResourceDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore downloadDataByName:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)downloadResource: (NSString *)resourceId toFile: (NSString *)filename withResourceDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore downloadFileByName:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)getStreamingURLForResource: (NSString *)resourceId withResourceDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore getStreamingURL(ByName):completionBlock:] instead, 1.18.0);

/** Downloads the given Resource ID into a local NSData object
 
 This method should be used to download a resource from Kinvey into a local NSData object.
 
 @param resourceId The Resource ID to download.
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)downloadResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore downloadDataByName:completionBlock:progressBlock:] instead, 1.18.0);

/** Downloads the given Resource ID into a local file.
 
 This method should be used to download a resource from Kinvey into a local File.  The file can then be used to access the resource.
 
 @param resourceId The Resource ID to download.
 @param filename The filename that the resource will use as the download location.  This will be set in the KCSResourceResponse that the delegate receives. 
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)downloadResource: (NSString *)resourceId toFile: (NSString *)filename completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore downloadFileByName:completionBlock:progressBlock:] instead, 1.18.0);

/** Obtain a 30-second time-limited URL for streaming a resource stored on Kinvey.
 
 This method is used for large objects stored on the Resource Service.  It's used to get a URL that allows the resource to be
 streamed to the device.
 
 @param resourceId The Resource ID to stream
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block is NEVER called, so just supply `nil`. 
 */
+ (void)getStreamingURLForResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore getStreamingURL(ByName):completionBlock:] instead, 1.18.0);

///---------------------------------------------------------------------------------------
/// @name Uploading Resources
///---------------------------------------------------------------------------------------

+ (void)saveLocalResource: (NSString *)filename withDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)saveLocalResourceWithURL: (NSURL *)URL withDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)saveLocalResource: (NSString *)filename toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)saveLocalResourceWithURL: (NSURL *)URL toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate  KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);
+ (void)saveData: (NSData *)data toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);

/** Saves the given File to Kinvey.
 
 This method is used to upload a local file to Kinvey, the resource ID will be the last path component of the filename with extension.
 
 @param filename The filename of the local file to upload.
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)saveLocalResource: (NSString *)filename completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);


/** Saves the given URL to Kinvey.
 
 This method is used to upload a local file to Kinvey, the resource ID will be the last path component of the filename with extension.
 
 @param URL The file URL of the local file to upload.
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)saveLocalResourceWithURL: (NSURL *)URL  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);

/** Saves the given File into the specified resource.
 
 This method is used to upload a local file to Kinvey, use this varient to specify an exact remote resource ID.
 
 @param filename The filename of the local file to upload.
 @param resourceId The resource ID to use for remote storage
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)saveLocalResource: (NSString *)filename toResource: (NSString *)resourceId  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);

/** Saves the given URL into the specified resource.
 
 This method is used to upload a local file to Kinvey, use this varient to specify an exact remote resource ID.
 
 @param URL The URL of the local file to upload.
 @param resourceId The resource ID to use for remote storage
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)saveLocalResourceWithURL: (NSURL *)URL toResource: (NSString *)resourceId  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadFile:options:completionBlock:progressBlock:] instead, 1.18.0);

/** Saves the given Data into the specified resource.
 
 This method is used to upload NSData into the Kinvey service.
 
 @param data The Data to upload to Kinvey.
 @param resourceId The resource ID to use for remote storage
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)saveData: (NSData *)data toResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore uploadData:options:completionBlock:progressBlock:] instead, 1.18.0);

///---------------------------------------------------------------------------------------
/// @name Deleting Resources
///---------------------------------------------------------------------------------------

+ (void)deleteResource:(NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore deleteFile:completionBlock:] instead, 1.18.0);

/** Delete the given resource from Kinvey.
 
 Use this method to delete a given resource from Kinvey.  Additional attempts to access this resource will fail with error code 404.
 
 @param resourceId The resource ID that should be removed.
 @param completionBlock the block called when the operation completes or fails
 @param progressBlock the block called 0+ times while the operation is in progress
 */
+ (void)deleteResource:(NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock KCS_DEPRECATED(delegate API is deprecated - use +[KCSFileStore deleteFile:completionBlock:] instead, 1.18.0);


@end
