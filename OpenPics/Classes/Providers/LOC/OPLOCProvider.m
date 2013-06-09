//
//  OPLOCProvider.m
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


#import "OPLOCProvider.h"
#import "AFLOCAPIClient.h"
#import "OPImageItem.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeLOC = @"com.saygoodnight.loc";

@implementation OPLOCProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Library of Congress";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    NSDictionary* parameters = @{
                             @"q" : queryString,
                             @"sp" : pageNumber,
                             @"fo" : @"json",
                             @"c" : @"100"
                             };

    
    [[AFLOCAPIClient sharedClient] getPath:@"search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        
        NSArray* resultArray = responseObject[@"results"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            NSDictionary* imageDict = itemDict[@"image"];
            if (imageDict) {
                NSURL* imageUrl = [NSURL URLWithString:imageDict[@"full"]];
                NSString* titleString = @"";
                if (itemDict[@"title"]) {
                    titleString = itemDict[@"title"];
                }
                NSMutableDictionary* providerSpecific = [NSMutableDictionary dictionary];

                NSURL* providerUrl = nil;
                if (itemDict[@"links"]) {
                    providerSpecific[@"links"] = itemDict[@"links"];
                    if ([itemDict[@"links"] isKindOfClass:[NSDictionary class]]) {
                        providerUrl = [NSURL URLWithString:itemDict[@"links"][@"item"]];
                    }
                }

                NSMutableDictionary* opImageDict = [@{
                                              @"imageUrl": imageUrl,
                                              @"title" : titleString,
                                              @"providerType": self.providerType,
                                              @"providerSpecific": providerSpecific
                                              } mutableCopy];
                if (providerUrl) {
                    opImageDict[@"providerUrl"] = providerUrl;
                }
                
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];                
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSDictionary* pagesDict = responseObject[@"pages"];
        NSInteger thisPage = [pagesDict[@"current"] integerValue];
        NSInteger totalPages = [pagesDict[@"total"] integerValue];
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
}

// Nothing to see here....please move along
- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    NSDictionary* providerSpecific = item.providerSpecific;
    if (providerSpecific[@"links"]) {
        NSDictionary* linksDict = providerSpecific[@"links"];
        if (linksDict[@"resource"]) {
            NSString* resourceUrlString = [NSString stringWithFormat:@"%@?fo=json",linksDict[@"resource"]];
            NSURL* url = [NSURL URLWithString:resourceUrlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
            AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

                NSString* urlString = item.imageUrl.absoluteString;
                if (JSON[@"resource"]) {
                    NSDictionary* resourceDict = JSON[@"resource"];
                    NSInteger largestSize = [resourceDict[@"largest_s"] intValue];
                    NSInteger largerSize = [resourceDict[@"larger_s"] intValue];
                    NSInteger largeSize = [resourceDict[@"large_s"] intValue];
                    
                    if ((largestSize > 0) && (largestSize < 12582912)) {
                        urlString = resourceDict[@"largest"];
                    } else if ((largerSize > 0) && (largerSize < 12582912)) {
                        urlString = resourceDict[@"larger"];
                    } else if ((largeSize > 0) && (largeSize < 12582912)) {
                        urlString = resourceDict[@"large"];
                    }
                }

                if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
                    if (completion) {
                        completion([NSURL URLWithString:urlString],item);
                    }
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"%@",error);
            }];
            [operation start];
        }
    }
    
}


@end
