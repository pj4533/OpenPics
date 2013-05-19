//
//  KinveyKit.h
//  KinveyKit
//
//  Copyright (c) 2008-2013, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.


#ifndef KinveyKit_h
#define KinveyKit_h

#import "KinveyVersion.h"
#import "KCSClient.h"
#import "KCSEntityDict.h"
#import "KinveyCollection.h"
#import "KinveyEntity.h"
#import "KinveyPersistable.h"
#import "KCSMetadata.h"
#import "KCSBlobService.h"
#import "KinveyPing.h"
#import "KinveyUser.h"
#import "KCSUserDiscovery.h"
#import "KCSReachability.h"
#import "KinveyErrorCodes.h"
#import "KCSQuery.h"
#import "KCSStore.h"

#import "KCSStore.h"
#import "KCSAppdataStore.h"
#import "KCSResourceStore.h"
#import "KCSCachedStore.h"
#import "KCSGroup.h"
#import "KCSReduceFunction.h"
#import "KCSLinkedAppdataStore.h"
#import "KCSOfflineSaveStore.h"

#import "KCSLogSink.h"


#if TARGET_OS_IPHONE
#import "KCSPush.h"
#import "KinveyAnalytics.h"

#endif

//UI & Framework Helpers
#import "CLLocation+Kinvey.h"
#import "KinveyKitExtras.h"

#endif
