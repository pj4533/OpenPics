//
//  AFNYPLAPIClient.h
//
//  Created by PJ Gray on 3/16/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@class Menu;
@interface AFNYPLAPIClient : AFHTTPClient

+ (AFNYPLAPIClient *)sharedClient;

- (void)getItemsWithParameters:(NSDictionary*) parameters
                       success:(void (^)(NSArray* items))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
