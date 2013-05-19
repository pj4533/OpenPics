//
//  KCSBlobService.h
//  SampleApp
//
//  Copyright (c) 2008-2011, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>
#import "KCSBlockDefs.h"

@class KCSClient;

/*! Container for Resource responses.
 
 This represents the results from a Resource request.  Because the resource may be eventually fetched from another sericve that doesn't respond
 in the same fashion as Kinvey, we have a slightly different response format for Resources than for other Kinvey items.
 
*/
@interface KCSResourceResponse : NSObject

///---------------------------------------------------------------------------------------
/// @name Resource Information
///---------------------------------------------------------------------------------------

/*! Contains the local filename that the Resource was saved to. */
@property (copy) NSString *localFileName;

/*! Contains the streaming URL if it was requested. */
@property (copy) NSString *streamingURL;

/*! Contains the Resource ID, which is used to uniquely identify this resource .*/
@property (copy) NSString *resourceId;

 /*! Contains the actual data for the resources. */
@property (strong) NSData *resource;

/*! Contains the "expected" size of the resource. */
@property NSInteger length;

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/*! Returns an autoreleased Resource Response.
 
 Responses can only be built using this method.  There are no facilities for editing a resource, so they are effectively immutable.  The lifetime of
 a response is limited and any data should be retained elsewhere if it is required (such as the NSData representing the resource.
 
 @param localFile The local filename that this resource was saved inot, nil of no local filename.
 @param resourceId The unique ID that identifies this resource in the Kinvey Cloud.
 @param resource The actual data of the resource.  The data must be converted to a different representation to use.  Nil for an upload/delete response.
 @param streamingURL The URL used to stream the resource, nil if not available for streaming.
 @param length The length of the response.  Should be set to match the expected length as given by the server.
 @return An Autoreleased KCSResourceResponse that can be used to obtain the response information.
 
 */
+ (KCSResourceResponse *)responseWithFileName: (NSString *)localFile withResourceId: (NSString *)resourceId withStreamingURL:(NSString *)streamingURL withData: (NSData *)resource withLength: (NSInteger)length;

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

/*! Kinvey Resource Helper
 
 This class is used to provide access to all Kinvey Resource services.
 */
@interface KCSResourceService : NSObject

///---------------------------------------------------------------------------------------
/// @name Downloading Resources
///---------------------------------------------------------------------------------------

/*! Downloads the given Resource ID into a local NSData object
 
 This method should be used to download a resource from Kinvey into a local NSData object.
 
 @param resourceId The Resource ID to download.
 @param delegate The delegate to be notified upon completion of the request.  The delegate will be provided a KCSResourceResponse that contains the data.
 */
+ (void)downloadResource: (NSString *)resourceId withResourceDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)downloadResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Downloads the given Resource ID into a local file.
 
 This method should be used to download a resource from Kinvey into a local File.  The file can then be used to access the resource.
 
 @param resourceId The Resource ID to download.
 @param filename The filename that the resource will use as the download location.  This will be set in the KCSResourceResponse that the delegate receives. 
 @param delegate The delegate to be notified upon completion of the request.
 */
+ (void)downloadResource: (NSString *)resourceId toFile: (NSString *)filename withResourceDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)downloadResource: (NSString *)resourceId toFile: (NSString *)filename completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Obtain a 30-second time-limited URL for streaming a resource stored on Kinvey.
 
 This method is used for large objects stored on the Resource Service.  It's used to get a URL that allows the resource to be
 streamed to the device.
 
 @param resourceId The Resource ID to stream
 @param delegate The delegate to be notified upon completion of the request.
 */
+ (void)getStreamingURLForResource: (NSString *)resourceId withResourceDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)getStreamingURLForResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

///---------------------------------------------------------------------------------------
/// @name Uploading Resources
///---------------------------------------------------------------------------------------

/*! Saves the given File to Kinvey.
 
 This method is used to upload a local file to Kinvey, the resource ID will be the last path component of the filename with extension.
 
 @param filename The filename of the local file to upload.
 @param delegate The delegate to be notified upon completion of the save.
 */
+ (void)saveLocalResource: (NSString *)filename withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)saveLocalResource: (NSString *)filename completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Saves the given URL to Kinvey.
 
 This method is used to upload a local file to Kinvey, the resource ID will be the last path component of the filename with extension.
 
 @param URL The URL of the local file to upload.
 @param delegate The delegate to be notified upon completion of the save.
 */
+ (void)saveLocalResourceWithURL: (NSURL *)URL withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)saveLocalResourceWithURL: (NSURL *)URL  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Saves the given File into the specified resource.
 
 This method is used to upload a local file to Kinvey, use this varient to specify an exact remote resource ID.
 
 @param filename The filename of the local file to upload.
 @param resourceId The resource ID to use for remote storage
 @param delegate The delegate to be notified upon completion of the save.
 */
+ (void)saveLocalResource: (NSString *)filename toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)saveLocalResource: (NSString *)filename toResource: (NSString *)resourceId  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Saves the given URL into the specified resource.
 
 This method is used to upload a local file to Kinvey, use this varient to specify an exact remote resource ID.
 
 @param URL The URL of the local file to upload.
 @param resourceId The resource ID to use for remote storage
 @param delegate The delegate to be notified upon completion of the save.
 */
+ (void)saveLocalResourceWithURL: (NSURL *)URL toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)saveLocalResourceWithURL: (NSURL *)URL toResource: (NSString *)resourceId  completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

/*! Saves the given Data into the specified resource.
 
 This method is used to upload NSData into the Kinvey service.
 
 @param data The Data to upload to Kinvey.
 @param resourceId The resource ID to use for remote storage
 @param delegate The delegate to be notified upon completion of the save.
 */
+ (void)saveData: (NSData *)data toResource: (NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)saveData: (NSData *)data toResource: (NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;

///---------------------------------------------------------------------------------------
/// @name Deleting Resources
///---------------------------------------------------------------------------------------

/*! Delete the given resource from Kinvey.
 
 Use this method to delete a given resource from Kinvey.  Additional attempts to access this resource will fail with error code 404.
 
 @param resourceId The resource ID that should be removed.
 @param delegate The delegate to be notified that the deletion action finished.
 */
+ (void)deleteResource:(NSString *)resourceId withDelegate: (id<KCSResourceDelegate>)delegate;
+ (void)deleteResource:(NSString *)resourceId completionBlock: (KCSCompletionBlock)completionBlock progressBlock: (KCSProgressBlock)progressBlock;


@end
