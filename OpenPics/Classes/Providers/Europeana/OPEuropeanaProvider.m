//
//  OPEuropeanaProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/19/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPEuropeanaProvider.h"
#import "OPProviderTokens.h"
#import "AFEuropeanaClient.h"
#import "OPImageItem.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeEuropeana = @"com.saygoodnight.europeana";

@implementation OPEuropeanaProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Europeana";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    NSMutableDictionary* parameters = [@{
                                 @"query":queryString,
                                 @"rows" : @"50",
                                 @"qf" : @"image"
                                 } mutableCopy];
    
    NSNumber* startItem = @(((pageNumber.integerValue - 1) * 50) + 1);
    if (![pageNumber isEqualToNumber:@1]) {
        parameters[@"start"] = startItem;
    }

    [[AFEuropeanaClient sharedClient] getPath:@"search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray* resultArray = responseObject[@"items"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {

            NSArray* edmPreview = itemDict[@"edmPreview"];
            if (edmPreview && edmPreview.count) {
                NSString* urlString = edmPreview[0];
                NSURL* imageUrl = [NSURL URLWithString:urlString];
                NSString* titleString = @"";
                if (itemDict[@"title"]) {
                    NSArray* titleArray = itemDict[@"title"];
                    if (titleArray.count) {
                        titleString = titleArray[0];
                    }
                }
                NSDictionary* opImageDict = @{
                                              @"imageUrl": imageUrl,
                                              @"title" : titleString,
                                              @"providerSpecific" : @{@"europeanaItem":itemDict[@"link"]}
                                              };
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSString* itemsCount = responseObject[@"itemsCount"];
        NSString* totalResults = responseObject[@"totalResults"];
        if ((itemsCount.integerValue + startItem.integerValue) < totalResults.integerValue) {
            returnCanLoadMore = YES;
        }

        if (completion) {
            completion(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion {
//    NSDictionary* providerSpecific = item.providerSpecific;
//    
//    NSString* europeanaItem = providerSpecific[@"europeanaItem"];
//    NSLog(@"%@", europeanaItem);
//    NSURL* url = [NSURL URLWithString:europeanaItem];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        
//        NSLog(@"%@", JSON);
//        NSDictionary* imageInfo = JSON[@"imageinfo"];
//        if (imageInfo) {
//            if (completion) {
//                completion([NSURL URLWithString:@""]);
//            }
//        }
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        NSLog(@"image info error: %@", error);
//    }];
//    [operation start];
}

@end
