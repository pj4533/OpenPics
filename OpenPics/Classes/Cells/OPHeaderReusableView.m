//
//  OPHeaderReusableView.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (IBAction)providerTapped:(id)sender {
    if (self.delegate) {
        self.internalTextField.text = @"";
        
        [self.delegate providerTappedFromRect:self.providerButton.frame inView:self];
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

#pragma mark Notifications

- (void) keyboardDidHide:(id) note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.delegate) {
        [self.delegate doSearchWithQuery:self.internalTextField.text];
    }
}
@end
