//
//  OPAnnotationView.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPAnnotationView.h"
#import "OPAnnotation.h"
#import "OPImageItem.h"
#import "AFNetworking.h"

@implementation OPAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>) annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [UIImage imageNamed:@"photo_pin"];
        
        OPAnnotation* opAnnotation = (OPAnnotation*) annotation;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        self.leftCalloutAccessoryView = imageView;
        [imageView setImageWithURL:opAnnotation.item.imageUrl];
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
