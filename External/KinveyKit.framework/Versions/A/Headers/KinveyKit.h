//
//  KinveyKit.h
//  KinveyKit
//
//  Copyright (c) 2008-2014, Kinvey, Inc. All rights reserved.
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


#ifndef KinveyKit_h
#define KinveyKit_h

#import "KinveyVersion.h"

#import "KCSClientConfiguration.h"
#import "KCSClient.h"

#import "KCSEntityDict.h"
#import "KinveyCollection.h"
#import "KinveyEntity.h"
#import "KinveyPersistable.h"
#import "KCSMetadata.h"
#import "KinveyPing.h"
#import "KinveyUser.h"
#import "KCSUserDiscovery.h"
#import "KCSReachability.h"
#import "KinveyErrorCodes.h"
#import "KCSQuery.h"
#import "KCSStore.h"
#import "KCSCustomEndpoints.h"

#import "KCSStore.h"
#import "KCSAppdataStore.h"
#import "KCSCachedStore.h"
#import "KCSGroup.h"
#import "KCSReduceFunction.h"
#import "KCSLinkedAppdataStore.h"
#import "KCSOfflineUpdateDelegate.h"
#import "KCSClient+KinveyDataStore.h"

#import "KCSFile.h"
#import "KCSBlobService.h"
#import "KCSResourceStore.h"
#import "KCSFileStore.h"

#import "KCSLogSink.h"


#if TARGET_OS_IPHONE
#import "KCSPush.h"

#endif

//UI & Framework Helpers
#import "CLLocation+Kinvey.h"
#import "KinveyKitExtras.h"

#endif
