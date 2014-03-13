//
//  OPNYPLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
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


#import "OPNYPLProvider.h"
#import "OPProviderTokens.h"
#import "AFNYPLSessionManager.h"
#import "OPImageItem.h"

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
        
        NSURL* providerUrl = nil;
        if (itemDict[@"itemLink"]) {
            providerUrl = [NSURL URLWithString:itemDict[@"itemLink"]];
        }
        
        NSMutableDictionary* opImageDict = [@{
                                      @"imageUrl": imageUrl,
                                      @"title" : titleString,
                                      @"providerType": self.providerType
                                      } mutableCopy];
        if (providerUrl) {
            opImageDict[@"providerUrl"] = providerUrl;
        }
        
        OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
        return item;
    }
    return nil;
}

- (BOOL) isConfigured {
#ifndef kOPPROVIDERTOKEN_NYPL
#warning *** WARNING: Make sure you have added your NYPL token to OPProviderTokens.h!
    return NO;
#else
    return YES;
#endif
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {

#ifdef kOPPROVIDERTOKEN_NYPL
    NSDictionary* parameters = @{
                                 @"q":queryString,
                                 @"per_page" : @"50",
                                 @"page":pageNumber
                                 };
    
    AFNYPLSessionManager* nyplClient = [AFNYPLSessionManager sharedClientWithToken:kOPPROVIDERTOKEN_NYPL];
    NSLog(@"GET items/search.json %@", parameters);
    
    [nyplClient GET:@"items/search.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
#endif
}

@end
