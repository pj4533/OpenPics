//
//  OPAnnotationView.h
//  OpenPics
//
//  Created by PJ Gray on 4/24/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPAnnotation.h"

@protocol OPAnnotationDelegate <NSObject>
    -(void)annotationButtonTapped:(OPAnnotation*) annotation;
@end

@interface OPAnnotationView : MKPinAnnotationView

@property (strong, nonatomic) id delegate;

@end
