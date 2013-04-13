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
                                 @"sourceResource.format" : @"*mage*",
                                 @"page_size" : @"50",
                                 @"page":pageNumber
                                 };
    

    NSLog(@"(DPLA GET) %@", parameters);
    
    [[AFDPLAClient sharedClient] getPath:@"items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* resultArray = responseObject[@"docs"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            
            
            NSString* urlString = itemDict[@"object"];
            if (urlString) {
                //            NSDictionary* providerDict = itemDict[@"provider"];
                //            NSString* providerName = providerDict[@"name"];
                //            if ([providerName isEqualToString:@"Digital Library of Georgia"]) {
                //                NSArray* colonSepComponents = [urlString componentsSeparatedByString:@":"];
                //                NSString* objectId = colonSepComponents.lastObject;
                //                NSString* objectIdFilename = [NSString stringWithFormat:@"%d", objectId.integerValue + 1];
                //                urlString = [NSString stringWithFormat:@"http://digitalcollections.library.gsu.edu/utils/getdownloaditem/collection/lane/id/%@/type/singleitem/filename/%@.jp2", objectId, objectIdFilename];
                //            }
                
                NSURL* imageUrl = [NSURL URLWithString:urlString];
                NSString* titleString = @"";
                NSDictionary* opImageDict = @{@"imageUrl": imageUrl, @"title" : titleString};
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];                
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSInteger startItem = [responseObject[@"start"] integerValue];
        NSInteger lastItem = startItem + retArray.count;
        NSInteger totalItems = [responseObject[@"count"] integerValue];
        if (lastItem < totalItems) {
            returnCanLoadMore = YES;
        }
        
        if (completion) {
            completion(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

@end
