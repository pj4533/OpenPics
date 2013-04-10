//
//  AFNYPLAPIClient.h
//
//  Created by PJ Gray on 3/16/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFNYPLAPIClient : AFHTTPClient

+ (AFNYPLAPIClient *)sharedClientWithToken:(NSString*) token;

@end
