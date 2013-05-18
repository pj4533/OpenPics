//
//  OPProviderController.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPProviderController.h"
#import "OPProvider.h"

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
    if (!_providers) {
        _providers = [NSMutableArray array];
    }
    
    [_providers addObject:provider];
}

- (OPProvider*) getFirstProvider {
    if (_providers.count) {
        return _providers[0];
    }
    
    return nil;
}

- (OPProvider*) getProviderWithType:(NSString*) providerType {
    for (OPProvider* thisProvider in _providers) {
        if ([thisProvider.providerType isEqualToString:providerType])
            return thisProvider;
    }
    
    return nil;
}

- (BOOL) isSupportedProviderType:(NSString*) providerType {
    for (OPProvider* thisProvider in _providers) {
        if ([thisProvider.providerType isEqualToString:providerType])
            return YES;
    }
    
    return NO;
}


- (NSArray*) getProviders {
    return _providers;
}

@end
