//
//  OPHeaderReusableView.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPHeaderReusableView.h"
#import "OPProvider.h"

@implementation OPHeaderReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)searchTapped:(id)sender {
    [self.internalTextField resignFirstResponder];

    if (self.delegate) {
        [self.delegate doSearchWithQuery:self.internalTextField.text];
    }
}

- (IBAction)providerTapped:(id)sender {
    if (self.delegate) {
        self.internalTextField.text = @"";
        
        [self.delegate providerTappedFromRect:self.providerButton.frame];
    }
}

- (IBAction)mapTapped:(id)sender {
    if (self.delegate) {
        [self.delegate flipToMap];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.internalTextField) {
        [self searchTapped:textField];
        return NO;
    }
    return YES;
}

@end
