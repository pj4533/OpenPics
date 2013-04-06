//
//  OPProviderController.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPProviderController.h"

@interface OPProviderController () {
    NSMutableArray* _providers;
}
@end

@implementation OPProviderController

+ (OPProviderController *)shared {
    static OPProviderController *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    
    return _shared;
}

- (void) addProvider:(OPProvider*) provider {
    [_providers addObject:provider];
}


@end
