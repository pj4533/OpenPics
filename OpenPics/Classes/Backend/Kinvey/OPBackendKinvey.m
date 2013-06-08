// OPBackendKinvey.m
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

#import "OPBackendKinvey.h"
#import "OPBackendTokens.h"
#import "OPImageItem.h"

#import <KinveyKit/KinveyKit.h>

@interface OPBackendKinvey () {
    KCSClient* _kinveyClient;
    KCSAppdataStore* _store;
}

@end

@implementation OPBackendKinvey

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
#ifdef kOPBACKEND_KINVEY_APP_KEY
    _kinveyClient = [[KCSClient sharedClient] initializeKinveyServiceForAppKey:kOPBACKEND_KINVEY_APP_KEY
                                                                 withAppSecret:kOPBACKEND_KINVEY_APP_SECRET
                                                                  usingOptions:nil];

    KCSCollection* collection = [KCSCollection collectionFromString:@"ImageItem" ofClass:[NSMutableDictionary class]];
    _store = [KCSAppdataStore storeWithCollection:collection options:nil];
    
    self.usingRemoteBackend = YES;
#endif
    return self;
}

- (void) getItemsWithKCSQuery:(KCSQuery*) query
               withPageNumber:(NSNumber*) pageNumber
                      success:(void (^)(NSArray* items, BOOL canLoadMore))success
                      failure:(void (^)(NSError* error))failure {

    query.limitModifer = [[KCSQueryLimitModifier alloc] initWithLimit:40];
    
    NSInteger countToStart = 0;
    if (pageNumber) {
        countToStart = (pageNumber.integerValue * 40) - 40;
    }
    
    query.skipModifier = [[KCSQuerySkipModifier alloc] initWithcount:countToStart];
    KCSQuerySortModifier* dateStort = [[KCSQuerySortModifier alloc] initWithField:@"date" inDirection:kKCSDescending];
    [query addSortModifier:dateStort];

    [_store countWithQuery:query completion:^(unsigned long count, NSError *errorOrNil) {
        [_store queryWithQuery:query withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil) {
                //An error happened, just log for now
                if (failure) {
                    failure(errorOrNil);
                }
                NSLog(@"An error occurred on fetch: %@", errorOrNil);
            } else {
                NSMutableArray* imageItems = [NSMutableArray array];
                for (NSDictionary* thisObject in objectsOrNil) {
                    OPImageItem* newImageItem = [[OPImageItem alloc] initWithDictionary:thisObject];
                    [imageItems addObject:newImageItem];
                }
                
                BOOL moreToLoad = NO;
                
                if ((countToStart + imageItems.count) < count) {
                    moreToLoad = YES;
                }
                
                if (success) {
                    success(imageItems,moreToLoad);
                }
            }
        } withProgressBlock:nil];
    }];    
}


#pragma mark OPBackend Overrides

- (void) saveItem:(OPImageItem*) item {
    [super saveItem:item];
    
    NSMutableDictionary* kinveyItem = [@{
                                       @"date":[NSDate date],
                                        @"imageUrl": item.imageUrl.absoluteString,
                                        @"providerType": item.providerType,
                                       @"lat": [NSString stringWithFormat:@"%f", item.location.latitude],
                                       @"lon": [NSString stringWithFormat:@"%f", item.location.longitude],
                                       @"width": [NSString stringWithFormat:@"%f", item.size.width],
                                       @"height": [NSString stringWithFormat:@"%f", item.size.height]
                                        } mutableCopy];

    if (item.providerUrl)
        kinveyItem[@"providerUrl"] = item.providerUrl.absoluteString;
    
    if (item.providerSpecific)
        kinveyItem[@"providerSpecific"] = item.providerSpecific;

    if (item.title)
        kinveyItem[@"title"] = item.title;

    [_store saveObject:kinveyItem withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil == nil) {
            //save was successful
            NSLog(@"Successfully saved item (id='%@').", [objectsOrNil[0] kinveyObjectId]);
        } else {
            NSLog(@"ERROR: %@", errorOrNil);
        }
    } withProgressBlock:nil];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    KCSQuery* query;
    
    if (queryString) {
        query = [KCSQuery queryOnField:@"title" withRegex:queryString options:kKCSRegexpCaseInsensitive];
    } else {
        query = [KCSQuery query];
    }
    
    [self getItemsWithKCSQuery:query withPageNumber:pageNumber success:success failure:failure];
}

@end
