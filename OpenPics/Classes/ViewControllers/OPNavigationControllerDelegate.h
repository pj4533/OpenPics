//
//  OPNavigationControllerDelegate.h
//  OpenPics
//
//  Created by PJ Gray on 3/23/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPNavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

+ (OPNavigationControllerDelegate *)shared;

@property BOOL transitioning;

@end
