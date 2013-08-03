// OPRedditProvider.m
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

#import "OPRedditProvider.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "OPImageItem.h"

NSString * const OPProviderTypeReddit = @"com.saygoodnight.Reddit";

@implementation OPRedditProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Reddit";
        self.supportsInitialSearching = YES;
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
//    [[OPBackend shared] getItemsCreatedByUserWithQuery:queryString
//                                        withPageNumber:pageNumber
//                                               success:success
//                                               failure:failure];
}


- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    
    AFHTTPClient* apiClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.reddit.com"]];
    [apiClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    NSDictionary* params = @{@"limit": @"100"};
    [apiClient getPath:@"/r/historyporn.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSMutableArray* retArray = [NSMutableArray array];
        NSArray* childrenArray = responseObject[@"data"][@"children"];
        for (NSDictionary* itemDict in childrenArray) {
            NSDictionary* dataDict = itemDict[@"data"];
            NSString* imageUrlString = dataDict[@"url"];
            
            if ([dataDict[@"domain"] isEqualToString:@"imgur.com"]) {
                imageUrlString = [imageUrlString stringByAppendingString:@".jpg"];
            }
            
            NSString* lowercaseTitle = [dataDict[@"title"] lowercaseString];
            lowercaseTitle = [lowercaseTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
            lowercaseTitle = [lowercaseTitle stringByReplacingOccurrencesOfString:@"," withString:@""];
            lowercaseTitle = [lowercaseTitle stringByReplacingOccurrencesOfString:@"×" withString:@"x"];
            NSRange openBracketRange = [lowercaseTitle rangeOfString:@"["];
            NSRange closeBracketRange = [lowercaseTitle rangeOfString:@"]"];
            int lengt = closeBracketRange.location - openBracketRange.location - 1;
            int location = openBracketRange.location + 1;
            NSRange sizeStringRange;
            sizeStringRange.location = location;
            sizeStringRange.length = lengt;
            NSString* sizeString = [lowercaseTitle substringWithRange:sizeStringRange];
            NSArray* sizeArray = nil;
            if (sizeString) {
                sizeArray = [sizeString componentsSeparatedByString:@"x"];
            }
            NSMutableDictionary* opImageDict = [@{
                                          @"imageUrl": [NSURL URLWithString:imageUrlString],
                                          @"title" : dataDict[@"title"],
                                          @"providerType": self.providerType,
                                          @"providerSpecific": dataDict
                                          } mutableCopy];
            
            if (sizeArray) {
                opImageDict[@"width"] = sizeArray[0];
                opImageDict[@"height"] = sizeArray[1];
            }
            
            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
            [retArray addObject:item];
        }
        
        BOOL returnCanLoadMore = NO;
//        NSInteger thisPage = [photosDict[@"page"] integerValue];
//        NSInteger totalPages = [photosDict[@"pages"] integerValue];
//        if (thisPage < totalPages) {
//            returnCanLoadMore = YES;
//        }

        if (success) {
            success(retArray,returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
