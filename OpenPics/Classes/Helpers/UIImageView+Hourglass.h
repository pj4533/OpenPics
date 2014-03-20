//
//  UIImageView+Hourglass.h
//  OpenPics
//
//  Created by PJ Gray on 3/19/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Hourglass)

- (void) fadeInHourglassWithCompletion:(void (^)(void))completion;

@end
