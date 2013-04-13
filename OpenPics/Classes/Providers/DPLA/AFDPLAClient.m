//
//  AFDPLAClient.m
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFDPLAClient.h"
#import "AFJSONRequestOperation.h"
#import "OPProviderTokens.h"

static NSString * const kAFDPLABaseURLString = @"http://api.dp.la/v2/";

@implementation AFDPLAClient

+ (AFDPLAClient *)sharedClient {
    static AFDPLAClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFDPLAClient alloc] initWithBaseURL:[NSURL URLWithString:kAFDPLABaseURLString]];
        
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
    
#ifndef kOPPROVIDERTOKEN_DPLA

#warning *** WARNING: Make sure you have added your DPLA token to OPProviderTokens.h!
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Token!"
                                                    message:@"No DPLA Token found. Add it to OPProviderTokens.h or use another image source."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
#else
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"api_key"] = kOPPROVIDERTOKEN_DPLA;
    
    [super getPath:path parameters:mutableParams success:success failure:failure];
    
#endif

}
@end