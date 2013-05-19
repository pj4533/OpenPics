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
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"No Token!"
                                                          message:@"No Europeana Token found. Add it to OPProviderTokens.h or use another image source."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
    if (failure) {
        failure(nil);
    }
#else
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"wskey"] = kOPPROVIDERTOKEN_EUROPEANA;

    [super getPath:path parameters:mutableParams success:success failure:failure];
    
#endif
    
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest* returnRequest = [super requestWithMethod:method path:path parameters:parameters];
    NSURL* requestUrl = returnRequest.URL;
    
    NSString* urlString = [requestUrl.absoluteString stringByReplacingOccurrencesOfString:@"%5B%5D" withString:@""];
    
    [returnRequest setURL:[NSURL URLWithString:urlString]];
    
    return returnRequest;
}

@end