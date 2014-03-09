//
//  KCSUser2.h
//  KinveyKit
//
//  Copyright (c) 2013-2014 Kinvey. All rights reserved.
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
@class KCSMetadata;

//TODO: need to handle auth for implementers...

@protocol KCSUser2 <NSObject, KCSPersistable>
/* This is the `KCSEntityKeyId` for the user object */
@property (nonatomic, copy) NSString* userId;
/* This is the `KCSUserAttributeUsername` for the user object */
@property (nonatomic, copy) NSString* username;
/* This is true if the user email has been verified */
@property (nonatomic) BOOL emailVerified;
/** Optional email address for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *email;

@end

@interface KCSUser2 : NSObject <KCSUser2>
/* This is the `KCSEntityKeyId` for the user object */
@property (nonatomic, copy) NSString* userId;
/* This is the `KCSUserAttributeUsername` for the user object */
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic) BOOL emailVerified;
/** Optional surname for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *surname;
/** Optional given (first) name for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *givenName;
/*! Access Control Metadata of this User
 @see KCSPersistable
 */
@property (nonatomic, strong) KCSMetadata *metadata;
/*! Device Tokens of this User */
@property (nonatomic, readonly, strong) NSMutableSet *deviceTokens;


@end
