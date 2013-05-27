// OPFlickrCommonsProvider.m
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

#import "OPFlickrCommonsProvider.h"
#import "AFFlickrAPIClient.h"
#import "OPImageItem.h"
#import "AFJSONRequestOperation.h"
#import "OPProviderTokens.h"

NSString * const OPProviderTypeFlickrCommons = @"com.saygoodnight.flickrcommons";

@implementation OPFlickrCommonsProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Flickr Commons Project";
    }
    return self;
}

- (BOOL) isConfigured {
#ifndef kOPPROVIDERTOKEN_FLICKR
#warning *** WARNING: Make sure you have added your Flickr token to OPProviderTokens.h!
    return NO;
#else
    return YES;
#endif
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    NSDictionary* parameters = @{
                                 @"text" : queryString,
                                 @"page": pageNumber,
                                 @"nojsoncallback": @"1",
                                 @"method" : @"flickr.photos.search",
                                 @"format" : @"json",
                                 @"is_commons": @"true",
                                 @"extras": @"url_b,url_o",
                                 @"per_page": @"20"
                                 };
    
    
    [[AFFlickrAPIClient sharedClient] getPath:@"services/rest" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* photosDict = responseObject[@"photos"];
        NSMutableArray* retArray = [NSMutableArray array];
        NSArray* photoArray = photosDict[@"photo"];
        for (NSDictionary* itemDict in photoArray) {
            NSString* farmId = itemDict[@"farm"];
            NSString* serverId = itemDict[@"server"];
            NSString* photoId = itemDict[@"id"];
            NSString* photoSecret = itemDict[@"secret"];
            
            NSString* imageUrlString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",farmId,serverId,photoId,photoSecret];
            NSDictionary* opImageDict = @{
                                          @"imageUrl": [NSURL URLWithString:imageUrlString],
                                          @"title" : itemDict[@"title"],
                                          @"providerType": self.providerType,
                                          @"providerSpecific": itemDict
                                          };
            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
            [retArray addObject:item];
        }
        
        BOOL returnCanLoadMore = NO;
        NSInteger thisPage = [photosDict[@"page"] integerValue];
        NSInteger totalPages = [photosDict[@"pages"] integerValue];
        if (thisPage < totalPages) {
            returnCanLoadMore = YES;
        }
        
        if (success) {
            success(retArray,returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {

    NSString* upRezzedUrlString = item.imageUrl.absoluteString;
    
    if (item.providerSpecific[@"url_o"]) {
        upRezzedUrlString = item.providerSpecific[@"url_o"];
    } else if (item.providerSpecific[@"url_b"]) {
        upRezzedUrlString = item.providerSpecific[@"url_b"];
    }

    if (completion && ![upRezzedUrlString isEqualToString:item.imageUrl.absoluteString]) {
        completion([NSURL URLWithString:upRezzedUrlString], item);
    }
}

@end
