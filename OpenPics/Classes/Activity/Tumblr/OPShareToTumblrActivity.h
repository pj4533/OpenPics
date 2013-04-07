//
//  SGShareToTumblrActivity.h
//
//  Created by PJ Gray on 9/14/12.
//  Copyright (c) 2012 PJ Gray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPTumblrPostViewController.h"
#import "OPActivityTokens.h"

extern NSString * const kTumblrCallbackURLString;
extern NSString* const UIActivityTypeShareToTumblr;

@interface OPShareToTumblrActivity : UIActivity <LPTumblrPostDelegate>

@end
