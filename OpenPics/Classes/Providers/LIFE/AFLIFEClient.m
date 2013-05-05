// AFLIFEClient.m
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

#import "AFLIFEClient.h"
#import "AFJSONRequestOperation.h"
#import "OPProviderTokens.h"

static NSString * const kAFLIFEBaseURLString = @"https://www.googleapis.com/";

@implementation AFLIFEClient

+ (AFLIFEClient *)sharedClient {
    static AFLIFEClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFLIFEClient alloc] initWithBaseURL:[NSURL URLWithString:kAFLIFEBaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void) getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
#ifndef kOPPROVIDERTOKEN_LIFE
    
#warning *** WARNING: Make sure you have added your LIFE token to OPProviderTokens.h!
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Token!"
                                                    message:@"No LIFE Token found. Add it to OPProviderTokens.h or use another image source."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
#else
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"key"] = kOPPROVIDERTOKEN_LIFE;
    
    [super getPath:path parameters:mutableParams success:success failure:failure];
    
#endif
    
}
@end