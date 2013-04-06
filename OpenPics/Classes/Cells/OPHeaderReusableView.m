//
//  OPHeaderReusableView.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPHeaderReusableView.h"

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

@end
