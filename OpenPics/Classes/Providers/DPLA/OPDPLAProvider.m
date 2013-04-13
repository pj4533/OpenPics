//
//  OPDPLAProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPDPLAProvider.h"
#import "OPImageItem.h"
#import "AFDPLAClient.h"

NSString * const OPProviderTypeDPLA = @"com.saygoodnight.dpla";

@implementation OPDPLAProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Digital Public Library of America";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
    NSDictionary* parameters = @{
                                 @"q":queryString,
//                                 @"hasView" : @"http",
                                 @"page_size" : @"50",
                                 @"page":pageNumber
                                 };
    

    NSLog(@"(DPLA GET) %@", parameters);
    
    [[AFDPLAClient sharedClient] getPath:@"items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* resultArray = responseObject[@"docs"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            
            
            id hasView = itemDict[@"hasView"];
            if (hasView) {
                NSString* urlString = nil;
                if ([hasView isKindOfClass:[NSDictionary class]] ) {
                    urlString = hasView[@"@id:"];
                } else if ([hasView isKindOfClass:[NSArray class]]) {
                    NSDictionary* firstObject = hasView[0];
                    urlString = firstObject[@"url"];
                }
                
                if (urlString) {
                    NSURL* imageUrl = [NSURL URLWithString:urlString];
                    NSString* titleString = @"";
                    
                    NSDictionary* sourceResourceDict = itemDict[@"sourceResource"];
                    if (sourceResourceDict) {
                        id title = sourceResourceDict[@"title"];
                        
                        if (title) {
                            if ([title isKindOfClass:[NSArray class]]) {
                                titleString = [title componentsJoinedByString:@", "];
                            } else if ([title isKindOfClass:[NSString class]])
                                titleString = title;
                            else
                                NSLog(@"ERROR TITLE IS: %@", [title class]);
                        }
                        
                        NSDictionary* opImageDict = @{@"imageUrl": imageUrl, @"title" : titleString};
                        OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                        [retArray addObject:item];
                    }
                }
            } else {
                NSString* urlString = itemDict[@"object"];
                if (urlString) {
                    NSURL* imageUrl = [NSURL URLWithString:urlString];
                    NSString* titleString = @"";
                    
                    NSDictionary* sourceResourceDict = itemDict[@"sourceResource"];
                    if (sourceResourceDict) {
                        id title = sourceResourceDict[@"title"];
                        
                        if (title) {
                            if ([title isKindOfClass:[NSArray class]]) {
                                titleString = [title componentsJoinedByString:@", "];
                            } else if ([title isKindOfClass:[NSString class]])
                                titleString = title;
                            else
                                NSLog(@"ERROR TITLE IS: %@", [title class]);
                        }
                        
                        NSDictionary* opImageDict = @{@"imageUrl": imageUrl, @"title" : titleString};
                        OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                        [retArray addObject:item];
                    }
                }
                
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSInteger startItem = [responseObject[@"start"] integerValue];
        NSInteger lastItem = startItem + resultArray.count;
        NSInteger totalItems = [responseObject[@"count"] integerValue];
        if (lastItem < totalItems) {
            returnCanLoadMore = YES;
        }
        
        NSLog(@"LAST: %d   TOTAL: %d", lastItem, totalItems);
        if (completion) {
            completion(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

@end
