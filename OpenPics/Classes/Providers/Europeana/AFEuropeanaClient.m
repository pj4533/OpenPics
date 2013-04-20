//
//  AFEuropeanaClient.m
//  OpenPics
//
//  Created by PJ Gray on 4/19/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "AFEuropeanaClient.h"
#import "OPProviderTokens.h"
#import "AFJSONRequestOperation.h"

static NSString * const kEuropeanaBaseURLString = @"http://europeana.eu/api/v2/";

@implementation AFEuropeanaClient

+ (AFEuropeanaClient *)sharedClient {
    static AFEuropeanaClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFEuropeanaClient alloc] initWithBaseURL:[NSURL URLWithString:kEuropeanaBaseURLString]];
        
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
    
#ifndef kOPPROVIDERTOKEN_EUROPEANA
    
#warning *** WARNING: Make sure you have added your Europeana token to OPProviderTokens.h!
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Token!"
                                                    message:@"No Europeana Token found. Add it to OPProviderTokens.h or use another image source."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
#else
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"wskey"] = kOPPROVIDERTOKEN_EUROPEANA;

    [super getPath:path parameters:mutableParams success:success failure:failure];
    
#endif
    
}

@end