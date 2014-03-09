//
//  KCSBlockDefs.h
//  KinveyKit
//
//  Created by Brian Wilson on 5/2/12.
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

#ifndef KinveyKit_KCSBlockDefs_h
#define KinveyKit_KCSBlockDefs_h

@class KCSGroup;

typedef void(^KCSCompletionBlock)(NSArray *objectsOrNil, NSError *errorOrNil);

/*! A progress block.
 @param objects if there are any valid objects available. Could be `nil` or empty.
 @param percentComplete the percentage of the total progress made so far. Suitable for a progress indicator.
 */
typedef void(^KCSProgressBlock)(NSArray *objects, double percentComplete);

/*! A completion block where the result is a coumt.
 @param count the resulting count of the operation
 @param errorOrNil an non-nil object if an error occurred.
 */
typedef void(^KCSCountBlock)(unsigned long count, NSError *errorOrNil);

typedef void(^KCSGroupCompletionBlock)(KCSGroup* valuesOrNil, NSError* errorOrNil);

#endif
