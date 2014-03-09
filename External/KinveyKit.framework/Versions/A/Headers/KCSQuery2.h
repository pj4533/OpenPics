//
//  KCSQuery2.h
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

@class KCSQuery;

typedef enum KCSQueryErrors : NSInteger {
    KCSqueryPredicateNotSupportedError = -3000
    } KCSQueryErrors;

@interface KCSQuery2 : NSObject

+ (instancetype) allQuery;
+ (instancetype) queryWithPredicate:(NSPredicate*)predicate error:(NSError**)error;
+ (instancetype) queryWithQuery1:(KCSQuery*)query;

@property (nonatomic, copy) NSArray* sortDescriptors; //of NSSortDescriptors
@property (nonatomic) NSUInteger limit;
@property (nonatomic) NSUInteger offset;

- (NSString *)escapedQueryString;

- (NSPredicate*) predicate;


@end
