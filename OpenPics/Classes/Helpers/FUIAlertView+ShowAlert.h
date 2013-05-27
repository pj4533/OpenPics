//
//  FUIAlertView+ShowAlert.h
//  OpenPics
//
//  Created by David Ohayon on 5/26/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "FUIAlertView.h"

@interface FUIAlertView (ShowAlert)
+ (void) showOkayAlertViewWithTitle:(NSString*)title message:(NSString*)message andDelegate:(id)delegate;
@end
