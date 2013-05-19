//
//  OPNYPLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPNYPLProvider.h"
#import "OPProviderTokens.h"
#import "AFNYPLAPIClient.h"
#import "OPImageItem.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeNYPL = @"com.saygoodnight.nypl";

@implementation OPNYPLProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"New York Public Library";
    }
    return self;
}

- (OPImageItem*) getItemFromDict:(NSDictionary*) itemDict {
    NSString* imageId = itemDict[@"imageID"];
    if (imageId) {
        NSString* urlString = [NSString stringWithFormat:@"http://images.nypl.org/index.php?id=%@&t=w", imageId];
        NSURL* imageUrl = [NSURL URLWithString:urlString];
        NSString* titleString = @"";
        if (itemDict[@"title"]) {
            titleString = itemDict[@"title"];
        }
        NSDictionary* opImageDict = @{
                                      @"imageUrl": imageUrl,
                                      @"title" : titleString,
                                      @"providerType": self.providerType
                                      };
        OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
        return item;
    }
    return nil;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {

#ifndef kOPPROVIDERTOKEN_NYPL
#warning *** WARNING: Make sure you have added your NYPL token to OPProviderTokens.h!
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"No Token!"
                                                          message:@"No NYPL Token found. Add it to OPProviderTokens.h or use another image source."
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
    
    failure(nil);
#else
    NSDictionary* parameters = @{
                                 @"q":queryString,
                                 @"per_page" : @"50",
                                 @"page":pageNumber
                                 };
    
    AFNYPLAPIClient* nyplClient = [AFNYPLAPIClient sharedClientWithToken:kOPPROVIDERTOKEN_NYPL];
    NSLog(@"GET items/search.json %@", parameters);
    
    [nyplClient getPath:@"items/search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* responseDict = responseObject[@"nyplAPI"][@"response"];
        id result = responseDict[@"result"];
        NSMutableArray* retArray = [NSMutableArray array];
        
        if ([result isKindOfClass:[NSArray class]]) {
            for (NSDictionary* itemDict in result) {
                OPImageItem* newItem = [self getItemFromDict:itemDict];
                if (newItem) {
                    [retArray addObject:newItem];
                }
            }
        } else if ([result isKindOfClass:[NSDictionary class]]){
            OPImageItem* newItem = [self getItemFromDict:result];
            if (newItem) {
                [retArray addObject:newItem];
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSDictionary* requestDictionary = responseObject[@"nyplAPI"][@"request"];
        NSInteger thisPage = [requestDictionary[@"page"] integerValue];
        NSInteger totalPages = [requestDictionary[@"totalPages"] integerValue];
        if (thisPage <= totalPages) {
            returnCanLoadMore = YES;
        }
        
        if (success) {
            success(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
#endif
}

@end
