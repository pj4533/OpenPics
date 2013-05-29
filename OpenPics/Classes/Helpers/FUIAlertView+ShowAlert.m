//
//  FUIAlertView+ShowAlert.m
//  OpenPics
//
//  Created by David Ohayon on 5/26/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "FUIAlertView+ShowAlert.h"

@implementation FUIAlertView (ShowAlert)

+ (void) showOkayAlertViewWithTitle:(NSString*)title message:(NSString*)message andDelegate:(id)delegate {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
}

@end
