//
//  OPDefaultBackend.m
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

#import "OPBackendDefault.h"
#import "OPImageItem.h"
#import "AFDefaultBackendSessionManager.h"

@implementation OPBackendDefault

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.usingRemoteBackend = YES;
    return self;
}

#pragma mark OPBackend Overrides

- (void) saveItem:(OPImageItem*) item {
    [super saveItem:item];
    
    NSMutableDictionary* backendItem = [@{
                                         @"imageUrl": item.imageUrl.absoluteString,
                                         @"providerType": item.providerType,
                                         @"width": [NSString stringWithFormat:@"%f", item.size.width],
                                         @"height": [NSString stringWithFormat:@"%f", item.size.height]
                                         } mutableCopy];
    
    if (item.providerUrl)
        backendItem[@"providerUrl"] = item.providerUrl.absoluteString;
    
    if (item.providerSpecific)
        backendItem[@"providerSpecific"] = item.providerSpecific;
    
    if (item.title)
        backendItem[@"title"] = item.title;
    
    [[AFDefaultBackendSessionManager sharedClient] POST:@"images" parameters:backendItem success:^(NSURLSessionDataTask *task, id responseObject) {
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {

    NSMutableDictionary* parameters = @{@"page" : @(pageNumber.integerValue-1) }.mutableCopy;
    
    if (queryString) {
        parameters[@"query"] = queryString;
    }
    
    [[AFDefaultBackendSessionManager sharedClient] GET:@"images" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber* thisPage = responseObject[@"paging"][@"page"];
        NSNumber* totalPages = responseObject[@"paging"][@"total_pages"];
        
        BOOL canLoadMore = NO;
        if (thisPage.integerValue < totalPages.integerValue) {
            canLoadMore = YES;
        }
        
        NSArray* images = responseObject[@"data"];
        NSMutableArray* returnItems = @[].mutableCopy;
        for (NSDictionary* image in images) {
            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:image];
            [returnItems addObject:item];
        }
        
        if (success) {
            success(returnItems, canLoadMore);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"ERROR: %@", error);
    }];
}

@end
