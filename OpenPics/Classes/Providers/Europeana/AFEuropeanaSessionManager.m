//
//  AFEuropeanaSessionManager.m
//  OpenPics
//
//  Created by PJ Gray on 4/19/13.
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


#import "AFEuropeanaSessionManager.h"
#import "OPProviderTokens.h"

static NSString * const kEuropeanaBaseURLString = @"http://europeana.eu/api/v2/";

@implementation AFEuropeanaSessionManager

+ (AFEuropeanaSessionManager *)sharedClient {
    static AFEuropeanaSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFEuropeanaSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kEuropeanaBaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (NSURLSessionDataTask *) GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSMutableDictionary* mutableParams = [parameters mutableCopy];

#ifdef kOPPROVIDERTOKEN_EUROPEANA
    mutableParams[@"wskey"] = kOPPROVIDERTOKEN_EUROPEANA;
#endif
    
    return [super GET:URLString parameters:mutableParams success:success failure:failure];
}

//- (NSMutableURLRequest *)
//- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
//                                      path:(NSString *)path
//                                parameters:(NSDictionary *)parameters
//{
//    
//    
//    NSMutableURLRequest* returnRequest = [super requestWithMethod:method path:path parameters:parameters];
//    NSURL* requestUrl = returnRequest.URL;
//    
//    NSString* urlString = [requestUrl.absoluteString stringByReplacingOccurrencesOfString:@"%5B%5D" withString:@""];
//    
//    [returnRequest setURL:[NSURL URLWithString:urlString]];
//    
//    return returnRequest;
//}

@end