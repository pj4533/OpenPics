//
//  KCSUserDiscovery.h
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
#import "KCSBlockDefs.h"

/**
 This class is for adding features that allow the current user to discover other users of the application */
@interface KCSUserDiscovery : NSObject

/** Find other users with the specified criteria.
 
 There are few by default public fields of the User collection.
 @param fieldMatchDictionary a `NSDictionary` with the keys being the user attributes to look-up, and the value the match criteria. Valid attribute keys are `KCSUserAttributeUsername`, `KCSUserAttributeSurname`, `KCSUserAttributeGivenname`, and `KCSUserAttributeEmail`.  The valid attributes are further described in the KCSUser doc.
 @param completionBlock the block to be called when the operation is complete or an error occurs. If the lookup is sucessful the value for `objectsOrNil` be a NSArray where each element is a `NSDictionary` providing all the public fields of the matching user(s). 
 @param progressBlock the block to be called during the lookup operation, if data is available. 
 @see KCSUser
 */
+ (void) lookupUsersForFieldsAndValues:(NSDictionary*)fieldMatchDictionary completionBlock:(KCSCompletionBlock)completionBlock progressBlock:(KCSProgressBlock)progressBlock;

@end
