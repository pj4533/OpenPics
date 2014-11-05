//
//  OPRedditProvider.m
//  OpenPics
//
//  Created by PJ Gray on 6/11/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "OPRedditProvider.h"
#import "OPItem.h"
#import "OPProviderTokens.h"
#import "AFHTTPSessionManager.h"
#import "NSString+ContainsSubstring.h"

@interface OPRedditProvider ()

// Reddit API uses 'after' hashes rather than page numbers, this is a mapping
@property (strong, nonatomic) NSMutableDictionary* pageNumberAfters;
@property (strong, nonatomic) NSString* currentQuery;

@end

@implementation OPRedditProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.pageNumberAfters = @{}.mutableCopy;
        self.currentQuery = @"";
    }
    return self;
}

- (BOOL) isConfigured {
    return YES;
}

- (void) doInitialSearchWithSubreddit:(NSString*) subreddit
                              success:(void (^)(NSArray* items, BOOL canLoadMore))success
                              failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:@""
             withPageNumber:@1
              withSubreddit:subreddit
                    success:success
                    failure:failure];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
             withSubreddit:(NSString*) subreddit
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    if (![queryString isEqualToString:self.currentQuery]) {
        self.pageNumberAfters = @{}.mutableCopy;
    }
    
    self.currentQuery = queryString;
    
    NSMutableDictionary* parameters = nil;
    
    if (pageNumber.integerValue > 1) {
        NSString* thisPageAfter = self.pageNumberAfters[pageNumber];
        if (thisPageAfter) {
            parameters = @{@"after" : thisPageAfter}.mutableCopy;
        }
    }

    NSString* path = [NSString stringWithFormat:@"/r/%@", subreddit];
    if (![queryString isEqualToString:@""]) {
        path = [path stringByAppendingString:@"/search.json"];
        if (!parameters) {
            parameters = @{@"q" : queryString, @"restrict_sr":@"on"}.mutableCopy;
        }
    } else {
        path = [path stringByAppendingString:@".json"];
    }

    NSURL* baseUrl = [[NSURL alloc] initWithString:@"http://www.reddit.com"];
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [manager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSDictionary* dataDict = responseObject[@"data"];
        NSString* after = dataDict[@"after"];
        if (after) {
            self.pageNumberAfters[@(pageNumber.integerValue+1)] = after;
        }
        
        NSMutableArray* retArray = [NSMutableArray array];
        NSArray* childrenArray = dataDict[@"children"];
        for (NSDictionary* itemDict in childrenArray) {
            NSDictionary* itemDataDict = itemDict[@"data"];
            
            NSString* urlString = itemDataDict[@"url"];
            NSString* domain = itemDataDict[@"domain"];
            
            // Only use imgur photos that aren't an album
            if (![urlString containsSubstring:@"imgur.com/a/"] && ![urlString containsSubstring:@"imgur.com/gallery"]) {
                if (domain && [domain containsSubstring:@"imgur.com"]) {
                    if (![urlString hasSuffix:@".jpg"] && ![urlString hasSuffix:@".gif"]) {
                        urlString = [urlString stringByAppendingString:@"l.jpg"];
                    } else {
                        if (![urlString hasSuffix:@"l.jpg"] && ![urlString hasSuffix:@".gif"]) {
                            urlString = [urlString stringByReplacingOccurrencesOfString:@".jpg" withString:@"l.jpg"];
                        }
                    }
                }
            }
            
            if ([urlString hasSuffix:@".jpg"] || [urlString hasSuffix:@".gif"]) {
                NSMutableDictionary* opImageDict = @{
                                                     @"imageUrl":[NSURL URLWithString:urlString],
                                                     @"title" : itemDataDict[@"title"],
                                                     @"providerType": self.providerType,
                                                     @"providerSpecific": itemDataDict,
                                                     }.mutableCopy;
                
                OPItem* item = [[OPItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];                
            }
        }
        
        BOOL returnCanLoadMore = NO;
        if (after) {
            returnCanLoadMore = YES;
        }
        
        if (success) {
            success(retArray,returnCanLoadMore);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) upRezItem:(OPItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion {
    
    NSString* upRezzedUrlString = item.imageUrl.absoluteString;
    
    if (item.providerSpecific[@"url"]) {
        NSString* domain = item.providerSpecific[@"domain"];
        NSString* urlString = item.providerSpecific[@"url"];
        if (domain && [domain isEqualToString:@"imgur.com"] && ![urlString hasSuffix:@".jpg"]) {
            urlString = [urlString stringByAppendingString:@".jpg"];
        }
        upRezzedUrlString = urlString;
    }
    
    if (completion && ![upRezzedUrlString isEqualToString:item.imageUrl.absoluteString]) {
        completion([NSURL URLWithString:upRezzedUrlString], item);
    }

}

@end
