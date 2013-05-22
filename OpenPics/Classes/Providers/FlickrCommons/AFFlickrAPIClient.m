// AFFlickrAPIClient.m
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

#import "AFFlickrAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "OPProviderTokens.h"

static NSString * const kAFFlickrAPIBaseURLString = @"http://api.flickr.com/";

@implementation AFFlickrAPIClient

+ (AFFlickrAPIClient *)sharedClient {
    static AFFlickrAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFFlickrAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFFlickrAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
//    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/javascript"]];

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void) getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
#ifdef kOPPROVIDERTOKEN_FLICKR
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"api_key"] = kOPPROVIDERTOKEN_FLICKR;
    
    [super getPath:path parameters:mutableParams success:success failure:failure];
#endif
}

@end
