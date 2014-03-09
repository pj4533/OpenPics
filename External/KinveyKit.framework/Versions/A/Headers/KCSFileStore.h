//
//  KCSFileStore.h
//  KinveyKit
//
// Copyright (c) 2013-2014, Kinvey, Inc. All rights reserved.
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

#import "KinveyCollection.h"
#import "KCSBlockDefs.h"

@class KCSFile;
@class KCSQuery;

/** The Upload Completion Block
 @param uploadInfo an object with the uploaded file's metadata
 @param error a non-nil object if the upload failed
 @since 1.18.0
 */
typedef void (^KCSFileUploadCompletionBlock)(KCSFile* uploadInfo, NSError* error);
/** The Download Completion Block
 @param downloadedResources an array of `KCSFile` objects representing the metadata and actual data or local file URL of the downloaded objects.
 @param error non-nil if any of the download request(s) failed
 @since 1.18.0
 */
typedef void (^KCSFileDownloadCompletionBlock)(NSArray* downloadedResources, NSError* error);
/** A Completion block for a streaming url request
 @param streamingResource the corresponding file metadata object. The `remoteURL` property will have the download location
 @param error non-nil if the request to get the URL failed
 @since 1.18.0
 */
typedef void (^KCSFileStreamingURLCompletionBlock)(KCSFile* streamingResource, NSError* error);

/** Sets the file id on the server side. */
FOUNDATION_EXPORT NSString* const KCSFileId;
/** Controls the access to the file. The value should be an instance of `KCSMetadata`. */
FOUNDATION_EXPORT NSString* const KCSFileACL;
/** The Mime-Type for the file. */
FOUNDATION_EXPORT NSString* const KCSFileMimeType;
/** The name of the file (both local or on the server). This name does not have to be unique. */
FOUNDATION_EXPORT NSString* const KCSFileFileName;
/** The projected size of the file */
FOUNDATION_EXPORT NSString* const KCSFileSize;
/** Option to only download the file if the server has been updated since the last download.*/
FOUNDATION_EXPORT NSString* const KCSFileOnlyIfNewer;
/** Option to only download the missing bytes of the file. */
FOUNDATION_EXPORT NSString* const KCSFileResume;
/** Option to make the file publicly available (whole internet) */
FOUNDATION_EXPORT NSString* const KCSFilePublic;

/** Internal Use Only */
FOUNDATION_EXPORT NSString* const KCSFileLinkExpirationTimeInterval; //Should be a NSTimerInterval (or double in seconds)


@interface KCSCollection (KCSFileStore)

/** Constant to represent the File metadata collection */
FOUNDATION_EXPORT NSString* const KCSFileStoreCollectionName;

/** Helper method to access the file store metadata. Objects will be `KCSFile` type. */
+ (instancetype) fileMetadataCollection;
@end

/** Methods for finding, downloading, uploading, and removing files from Kinvey's file storage.
 
 This class superceedes `KCSResourceService` and `KCSResourceStore`. Those classes' methods will no longer work.
 
 @since 1.18.0
 */
@interface KCSFileStore : NSObject

#pragma mark - Saving Files
///---------------------------------------------------------------------------------------
/// @name Creating & Updating Files
///---------------------------------------------------------------------------------------

/**
 Uploads a local file to Kinvey's file store
 
 Available options:

 * KCSFileFileName - the destination filename, if absent the source file's name will be used.
 * KCSFileId - the destination's unique resource id, if absent, one will be generated.
 * KCSFilePublic - set to `@(YES)` if the file it to be publicly available on the Internet.
 * KCSFileACL - provide a `KCSMetadata` object to set the read and write permissions. By default the file will only be available to the creating user.
 * KCSFileMimeType - the file's mime type. If absent, it will be inferred from the file extension. 
 * any other `options` fields will be set as properties on the metadata object
 
 @param fileURL         a url to a local file
 @param uploadOptions   upload options (see above)
 @param completionBlock called when the upload is complete or error occurs. The `KCSFile` return object will have its `filename` and `fileId` properties set to their new values.
 @param progressBlock   called 0+ times with intermediate progress as the file is uploaded. This only counts data transferred to the file storage service, and not the intermediate call to Kinvey to obtain the upload location.
 @since 1.18.0
 */
+ (void) uploadFile:(NSURL*)fileURL options:(NSDictionary*)uploadOptions completionBlock:(KCSFileUploadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/**
 Uploads binary data to Kinvey's file store
 
 Available options:
 
 * KCSFileFileName - the destination filename, if absent, one will be generated.
 * KCSFileId - the destination's unique resource id, if absent, one will be generated.
 * KCSFilePublic - set to `@(YES)` if the file it to be publicly available on the Internet.
 * KCSFileACL - provide a `KCSMetadata` object to set the read and write permissions. By default the file will only be available to the creating user.
 * KCSFileMimeType - the file's mime type. If absent, it will be `application/octet-stream`.
 * any other `options` fields will be set as properties on the metadata object
 
 @param data the bytes to upload
 @param uploadOptions upload options (see above)
 @param completionBlock called when the upload is complete or error occurs. The `KCSFile` return object will have its `filename` and `fileId` properties set to their new values.
 @param progressBlock called 0+ times with intermediate progress as the file is uploaded. This only counts data transferred to the file storage service, and not the intermediate call to Kinvey to obtain the upload location.
 @since 1.18.0
 */
+ (void) uploadData:(NSData*)data options:(NSDictionary*)uploadOptions completionBlock:(KCSFileUploadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;


#pragma mark - Downloading Files
///---------------------------------------------------------------------------------------
/// @name Downloading Files
///---------------------------------------------------------------------------------------

/** Downloads the specified file or files.
 
 The file(s) will be saved to the `NSCachesDirectory` and will be named by their `filename` properties. To override this behavior, supply a `KCSFileFileName` option to choose the file name. To keep the file in another directory, such as `NSDocumentsDirectory` (e.g. to have the file backed up) move the file after the download completes.
 
 Available options:
 
 * KCSFileOnlyIfNewer - set to `@(YES)` to only download if the metadata has been updated after the file was last downloaded (if file exists). 
 * KCSFileFileName - the destination filename. If multiple files are specified, this must be an array with the same number of elements as requested.
 
 @param idOrIds a single string file id or an array of file ids
 @param options an optional (can be `nil`) options dictionary (see above)
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `localURL`, `filename`, `fileId`, `length`, and `mimeType` properties filled.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadFile:(id)idOrIds options:(NSDictionary*)options completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the specified file or files.

 __NOTE:__ If there is no matching file by the specified name, the result will be an empty `downloadedResources` array, and NOT a 404 error. This is a change of behavior from previous versions.
 
 The file(s) will be saved to the `NSCachesDirectory`and will be named by their `filename` properties. 
 
 @param nameOrNames a single string file name or an array of file names
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `localURL`, `filename`, `fileId`, `length`, and `mimeType` properties filled. These objects may not be in the same order
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadFileByName:(id)nameOrNames completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the matching file or files.
 
 The file(s) will be saved to the `NSCachesDirectory`and will be named by their `filename` properties. 
 
 @param query a standard Kinvey Query object
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `localURL`, `filename`, `fileId`, `length`, and `mimeType` properties filled.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadFileByQuery:(KCSQuery*)query completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the specified URL.
 
 The file(s) will be saved to the `NSCachesDirectory`and will be named by their `filename` properties. To override this behavior, supply a `KCSFileFileName` option to choose the file name. To keep the file in another directory, such as `NSDocumentsDirectory` (e.g. to have the file backed up) move the file after the download completes.
 
 Available options:
 
 * KCSFileOnlyIfNewer - set to `@(YES)` to only download if the metadata has been updated after the file was last downloaded (if file exists).
 * KCSFileFileName - the destination filename. If no filename is provided, its name will be dervied from the filename of on the server.
 * KCSFileResume - set to `@(YES)` to only download the remaining bytes in the file. This assumes that the server file has not changed since the previous partial download.
 
 @param url a resolved GCS file URL. This request must be sucessfully sent before the `expirationTime` or the request will fail.
 @param options an optional (can be `nil`) options dictionary (see above)
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will have `KCSFile` object with its `localURL`, `filename`, `fileId`, `length`, and `mimeType` properties filled.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location.
 @since 1.18.0
 */
+ (void) downloadFileWithResolvedURL:(NSURL*)url options:(NSDictionary*)options completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the specified file or files to memory.
 
 @param idOrIds a single string file id or an array of file ids
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `filename`, `fileId`, `length`, and `mimeType` properties filled. The `data` property will contain the corresponing NSData values.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadData:(id)idOrIds completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the specified file or files to memory.
 
  __NOTE:__ If there is no matching file by the specified name, the result will be an empty `downloadedResources` array, and NOT a 404 error. This is a change of behavior from previous versions.
 
 @param nameOrNames a single string file name or an array of file names
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `filename`, `fileId`, `length`, and `mimeType` properties filled.  The `data` property will contain the corresponing NSData values.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadDataByName:(id)nameOrNames completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the matching file or files to memory.
 
 @param query a standard Kinvey Query object
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `filename`, `fileId`, `length`, and `mimeType` properties filled.  The `data` property will contain the corresponing NSData values.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location. This will be represented as a percentage of overall progress.
 @since 1.18.0
 */
+ (void) downloadDataByQuery:(KCSQuery*)query completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Downloads the specified URL to memory.
 
 @param url a resolved GCS file URL. This request must be sucessfully sent before the `expirationTime` or the request will fail.
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will have `KCSFile` object with its `filename`, `fileId`, `length`, and `mimeType` properties filled. The `data` property will contain the corresponing NSData values.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This only counts data transferred from the file storage service, and not the intermediate call to Kinvey to obtain the drownload location.
 @since 1.18.0
 */
+ (void) downloadDataWithResolvedURL:(NSURL*)url completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

/** Obtains a URL to stream the file. 
 
 This is useful for supplying to a `MPMoviePlayerController` or `MPMoviePlayerViewController`.
 
     [KCSFileStore getStreamingURL:@"ABCDEF-123456-8ACDEF" completionBlock:^(KCSFile* streamingResource, NSError* error) {
         if (error) //handle error & exit
         MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:streamingResource.remoteURL];
         //player setup & add to view hierarchy
         [player play];
      }];
 
 @param fileId the string file id
 @param completionBlock the block to be called once the url is ready, or error if it fails. The returned `KCSFile` object will have its `remoteURL` property be the streaming URL. This must be used before the `expirationDate` property has passed, or the url will be invalid and need to be re-retreived.
 @since 1.18.0
 */
+ (void) getStreamingURL:(NSString*)fileId completionBlock:(KCSFileStreamingURLCompletionBlock)completionBlock;

//with internal options
+ (void) getStreamingURL:(NSString *)fileId options:(NSDictionary*)options completionBlock:(KCSFileStreamingURLCompletionBlock)completionBlock;


/** Obtains a URL to stream the file.
 
 This is useful for supplying to a `MPMoviePlayerController` or `MPMoviePlayerViewController`.
 
     [KCSFileStore getStreamingURLByName:@"mymovie.mp4" completionBlock:^(KCSFile* streamingResource, NSError* error) {
         if (error) //handle error & exit
         MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:streamingResource.remoteURL];
         //player setup & add to view hierarchy
         [player play];
      }];
 
 @param fileName the string file name. If multiple files match, the first one will be used. 
 @param completionBlock the block to be called once the url is ready, or error if it fails. The returned `KCSFile` object will have its `remoteURL` property be the streaming URL. This must be used before the `expirationDate` property has passed, or the url will be invalid and need to be re-retreived.
 @since 1.18.0
 */
+ (void) getStreamingURLByName:(NSString*)fileName completionBlock:(KCSFileStreamingURLCompletionBlock)completionBlock;

/** Resumes a partially downloaded file. This method is useful if the a previous getFileXXX method failed mid-transfer, such as from loss of network connectivity or app backgrounding.
 
 See the devcenter guide for an example on how to use this function.
 
 @param partialLocalFile a file url to the already written data. This assumes the partial download's bytes are complete and contiguous up to its length.
 @param resolvedURL the GCS file URL to the original file (can be obtained with `getStreamingURL` methods or by querying the `fileMetadataCollection`.
 @param completionBlock called when the download(s) are complete or an error occurs. The downloadedResources array will be `KCSFile` objects with their `localURL`, `filename`, `fileId`, `length`, and `mimeType` properties filled. The `data` property will contain the corresponing NSData values.
 @param progressBlock called 0+ times with intermediate progress as the file is downloaded. This will count the total bytes to download, and thus will start with percentage previously downloaded. 
 @since 1.18.0
 */
+ (void) resumeDownload:(NSURL*)partialLocalFile from:(NSURL*)resolvedURL completionBlock:(KCSFileDownloadCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

#pragma mark - Deleting Files
///---------------------------------------------------------------------------------------
/// @name Deleting Files
///---------------------------------------------------------------------------------------

/** Removes a file from the file storage.
 
 @param fileId the file id. This can only be a single string
 @param completionBlock called when the operation completes or fails. The count will be 0 or 1 or an error will be provided.
 @since 1.18.0
 */
+ (void) deleteFile:(NSString*)fileId completionBlock:(KCSCountBlock)completionBlock;


/** Removes all downloaded files managed by KinveyKit.
 
 @since 1.24.0
 */
+ (void) clearCachedFiles;

@end
