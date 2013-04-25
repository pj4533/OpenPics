//
//  OPAnnotationView.m
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPAnnotationView.h"

@implementation OPAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>) annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [UIImage imageNamed:@"photo_pin"];
    }
    return self;
}

@end
