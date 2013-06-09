//
//  OPAnnotationView.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
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


#import "OPAnnotationView.h"
#import "OPAnnotation.h"
#import "OPImageItem.h"
#import "AFNetworking.h"

@implementation OPAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>) annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {        
        OPAnnotation* opAnnotation = (OPAnnotation*) annotation;

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        self.leftCalloutAccessoryView = self.imageView;
        [self.imageView setImageWithURL:opAnnotation.item.imageUrl];
        self.canShowCallout = YES;
        [self setEnabled:YES];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(gotoImage:) forControlEvents:UIControlEventTouchUpInside];
        self.rightCalloutAccessoryView = button;
    }
    return self;
}

- (IBAction) gotoImage:(id)sender {
    if (self.delegate) {
        [self.delegate annotationButtonTapped:self.annotation];
    }
}

@end
