//
//  KCSAnalytics+UniqueHardwareID.h
//  KinveyKit
//
//  Created by Brian Wilson on 1/10/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "KinveyAnalytics.h"

@interface KCSAnalytics (UniqueHardwareID)

- (NSString *)kinveyUDID;
- (NSString *)getMacAddress;

@end
