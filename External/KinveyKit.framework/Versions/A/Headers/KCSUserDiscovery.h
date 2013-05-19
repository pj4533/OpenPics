//
//  KCSUserDiscovery.h
//  KinveyKit
//
//  Created by Michael Katz on 7/13/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
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
