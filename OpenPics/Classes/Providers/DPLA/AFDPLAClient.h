//
//  AFDPLAClient.h
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFDPLAClient : AFHTTPClient

+ (AFDPLAClient *)sharedClient;

@end
