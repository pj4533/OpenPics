//
//  OPShareToRedditActivity.h
//  OpenPics
//
//  Created by David Ohayon on 5/25/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPRedditPostViewController.h"

extern NSString* const UIActivityTypeShareToReddit;

@interface OPShareToRedditActivity : UIActivity <OPRedditPostDelegate>

@end
