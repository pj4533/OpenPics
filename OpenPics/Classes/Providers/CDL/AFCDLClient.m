//
//  AFCDLClient.m
//  OpenPics
//
//  Created by PJ Gray on 4/10/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFCDLClient.h"
#import "AFKissXMLRequestOperation.h"

static NSString * const kAFCDLBaseURLString = @"http://content.cdlib.org/";

@implementation AFCDLClient

+ (AFCDLClient *)sharedClient {
    static AFCDLClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFCDLClient alloc] initWithBaseURL:[NSURL URLWithString:kAFCDLBaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFJSONParameterEncoding;
        
    [self registerHTTPOperationClass:[AFKissXMLRequestOperation class]];
        
	[self setDefaultHeader:@"Accept" value:@"application/xml"];
    
    return self;
}

@end