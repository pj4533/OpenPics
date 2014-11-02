//
//  OPRedditGenericProvider.h
//  OpenPics
//
//  Created by PJ Gray on 11/2/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditProvider.h"

extern NSString* const OPProviderTypeRedditGeneric;

@interface OPRedditGenericProvider : OPRedditProvider

- (id) initWithProviderType:(NSString*) providerType subredditName:(NSString*)subredditName;

@end
