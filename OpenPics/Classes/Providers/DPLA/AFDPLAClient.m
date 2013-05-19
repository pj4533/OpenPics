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
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"No Token!"
                                                          message:@"No DPLA Token found. Add it to OPProviderTokens.h or use another image source."
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
        failure(nil,nil);
    }
#else
    NSMutableDictionary* mutableParams = [parameters mutableCopy];
    mutableParams[@"api_key"] = kOPPROVIDERTOKEN_DPLA;
    
    [super getPath:path parameters:mutableParams success:success failure:failure];
    
#endif

}
@end