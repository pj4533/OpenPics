//
//  KCSConnectionProgress.h
//  KinveyKit
//
//  Copyright (c) 2008-2013, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>

/* Indication of current progress of a connection operation
 
 This object is used to provide current status of the remote operation in progress.
 
 @bug This feature is not yet implemented in the current version of Kinvey
 
 */
@interface KCSConnectionProgress : NSObject

@property (nonatomic, copy) NSData* data;
@property (nonatomic) double percentComplete;


@end
