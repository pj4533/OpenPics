//
//  OPLOCProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

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
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
    NSDictionary* parameters = @{
                             @"q" : queryString,
                             @"sp" : pageNumber,
                             @"fo" : @"json",
                             @"fa" : @"displayed:anywhere",
                             @"c" : @"100"
                             };

    
    [[AFLOCAPIClient sharedClient] getPath:@"search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSArray* resultArray = responseObject[@"results"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            NSDictionary* imageDict = itemDict[@"image"];
            if (imageDict) {
                NSURL* imageUrl = [NSURL URLWithString:imageDict[@"full"]];
                NSDictionary* opImageDict = @{@"imageUrl": imageUrl};
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];                
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSDictionary* pagesDict = responseObject[@"pages"];
        NSInteger thisPage = [pagesDict[@"current"] integerValue];
        NSInteger totalPages = [pagesDict[@"total"] integerValue];
        if (thisPage <= totalPages) {
            returnCanLoadMore = YES;
        }

        if (completion) {
            completion(retArray,returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

@end
