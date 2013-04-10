//
//  AFCDLClient.h
//  OpenPics
//
//  Created by PJ Gray on 4/10/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFCDLClient : AFHTTPClient

+ (AFCDLClient *)sharedClient;

@end
