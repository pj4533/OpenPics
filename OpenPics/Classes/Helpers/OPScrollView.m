//
//  OPScrollView.m
//
//  Created by PJ Gray on 2/5/13.
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


#import "OPScrollView.h"

@implementation OPScrollView


- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 10.0f;
        
        // then create the new object
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
        self.imageView.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
#warning fit or fill?
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.imageView];
    }
    
    return self;
    
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 10.0f;
        
        // then create the new object
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.imageView.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
#warning fit or fill
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.imageView];
    }
    
    return self;
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

// Pass the touches to the superview (the cell) if I ever need to get selection/highlighting working in single image mode
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    //    [self.superview touchesBegan:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    //    [self.superview touchesCancelled:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    //    [self.superview touchesEnded:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    //    [self.superview touchesMoved:touches withEvent:event];
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



@end