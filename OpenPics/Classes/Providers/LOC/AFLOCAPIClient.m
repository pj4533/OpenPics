//
//  AFLOCAPIClient.m
//  LOCPix
//
//  Created by PJ Gray on 8/12/12.
//  Copyright (c) 2012 PJ Gray. All rights reserved.
//

#import "AFLOCAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFLOCAPIBaseURLString = @"http://www.loc.gov/pictures/";

@implementation AFLOCAPIClient

+ (AFLOCAPIClient *)sharedClient {
    static AFLOCAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFLOCAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFLOCAPIBaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
