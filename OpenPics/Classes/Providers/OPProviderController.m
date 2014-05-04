//
//  OPProviderController.m
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


#import "OPProviderController.h"
#import "OPProvider.h"

@interface OPProviderController () {
    NSMutableArray* _providers;
    OPProvider* _selectedProvider;
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
    
    if ([provider isConfigured]) {
        [_providers addObject:provider];
    }
}

- (OPProvider*) getSelectedProvider {
    return _selectedProvider;
}

- (void) selectFirstProvider {
    _selectedProvider = _providers[0];
}

- (void) selectProvider:(OPProvider*) provider {
    _selectedProvider = provider;
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
