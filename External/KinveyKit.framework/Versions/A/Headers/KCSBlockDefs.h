//
//  KCSBlockDefs.h
//  KinveyKit
//
//  Created by Brian Wilson on 5/2/12.
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
//

#ifndef KinveyKit_KCSBlockDefs_h
#define KinveyKit_KCSBlockDefs_h

@class KCSGroup;

typedef void(^KCSCompletionBlock)(NSArray *objectsOrNil, NSError *errorOrNil);
typedef void(^KCSProgressBlock)(NSArray *objects, double percentComplete);
typedef void(^KCSCountBlock)(unsigned long count, NSError *errorOrNil);
typedef void(^KCSGroupCompletionBlock)(KCSGroup* valuesOrNil, NSError* errorOrNil);

#endif
