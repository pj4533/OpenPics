//
//  KCSFile.h
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

#import "KinveyPersistable.h"
#import "KCSMetadata.h"

/**
 This class is a wrapper for file store information.
 */
@interface KCSFile : NSObject <KCSPersistable, NSCoding, NSCopying>

///---
/// @name Basic Info
///---

/** The unique id of the file resource.
 */
@property (nonatomic, copy) NSString* fileId;

/** The file name (and extension) of the file. Does not have to be unique.
 */
@property (nonatomic, copy) NSString* filename;

/** The actual or expected size of the file.
 */
@property (nonatomic) NSUInteger length;

/** The file's type. 
 */
@property (nonatomic, copy) NSString* mimeType;

/** `YES` if the file is public on the Internet.
 
 @bug You can comment this out with no side effect if you're not using this property. If you are, switch to `publicFile`.
 
 @deprecated deprcated for 3p compatbility- use publicFile property instead
 @deprecatedIn 1.20.0
 */
@property (nonatomic, copy) NSNumber* public KCS_DEPRECATED(Use publicFile property instead, 1.20.0);

/** `YES` if the file is public on the Internet.
 @since 1.20.0
 */
@property (nonatomic, copy) NSNumber* publicFile;


/** Control a resource's ACLs.
 */
@property (nonatomic, retain) KCSMetadata* metadata;

///----
/// @name Downloaded Data
///---

/** The URL to the file where the resource was saved to.
 
 Either only `localURL` or `data` will be valid for downloaded data.
 */
@property (nonatomic, retain, readonly) NSURL* localURL;

/** The downloaded data.
 
 Either only `localURL` or `data` will be valid for downloaded data.
 */
@property (nonatomic, retain, readonly) NSData* data;

///----
/// @name Streaming Data
///---

/** The location of the remote resource on it's actual server.
 */
@property (nonatomic, retain, readonly) NSURL* remoteURL;

/** The date until the `remoteURL` is good until. After that, the url must be re-fetched from Kinvey.
 */
@property (nonatomic, retain, readonly) NSDate* expirationDate;


//---
// @name Uploading Data
//---

/** The number of bytes sent to GCS. If the file upload fails in the middle, this will be less than the total `length`. This value will be >= the number of byte actually received by the server.
 */
@property (nonatomic) unsigned long long bytesWritten;

#pragma mark - Linked Files API
//internal methods

@property (nonatomic, retain, readonly) id resolvedObject;

- (instancetype)initWithData:(NSData *)data fileId:(NSString*)fileId filename:(NSString*)filename mimeType:(NSString*)mimeType;
- (instancetype)initWithLocalFile:(NSURL *)localURL fileId:(NSString*)fileId filename:(NSString*)filename mimeType:(NSString*)mimeType;

+ (instancetype) fileRef:(id)objectToRef collectionIdProperty:(NSString*)idStr;
+ (instancetype) fileRefFromKinvey:(NSDictionary*)kinveyDict class:(Class)klass;
@end
