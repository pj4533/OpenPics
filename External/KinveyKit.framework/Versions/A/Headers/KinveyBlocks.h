//
//  KinveyBlocks.h
//  KinveyKit
//
//  Copyright (c) 2008-2012, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#ifndef KinveyKit_KinveyBlocks_h
#define KinveyKit_KinveyBlocks_h

@class KCSConnectionProgress;
@class KCSConnectionResponse;

// Define the block types that we expect
typedef void(^KCSConnectionProgressBlock)(KCSConnectionProgress* progress);
typedef void(^KCSConnectionCompletionBlock)(KCSConnectionResponse* response);
typedef void(^KCSConnectionFailureBlock)(NSError* error);



#endif
