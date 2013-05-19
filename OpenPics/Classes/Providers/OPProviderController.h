//
//  OPProviderController.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OPProvider;
@interface OPProviderController : NSObject

+ (OPProviderController *)shared;

- (void) addProvider:(OPProvider*) provider;

- (OPProvider*) getFirstProvider;
- (OPProvider*) getProviderWithType:(NSString*) providerType;
- (NSArray*) getProviders;

- (BOOL) isSupportedProviderType:(NSString*) providerType;

@end
