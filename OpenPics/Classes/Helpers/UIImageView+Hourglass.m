//
//  UIImageView+Hourglass.m
//  OpenPics
//
//  Created by PJ Gray on 3/19/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "UIImageView+Hourglass.h"

@implementation UIImageView (Hourglass)

- (void) fadeInHourglassWithCompletion:(void (^)(void))completion {
    self.alpha = 0.0f;
    
    // First, go to the main thread and set the imageview to hourglass, start with alpha at 0?
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentMode = UIViewContentModeCenter;
        self.image = [UIImage imageNamed:@"hourglass_white"];
        
        if (completion) {
            completion();
        }
        
        // fade in the hourglass
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
    });
}


@end
