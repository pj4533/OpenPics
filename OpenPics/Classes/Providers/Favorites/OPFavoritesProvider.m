// OPFavoritesProvider.m
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

#import "OPFavoritesProvider.h"
#import "OPImageItem.h"
#import "OPBackend.h"

NSString * const OPProviderTypeFavorites = @"com.saygoodnight.Favorites";

@implementation OPFavoritesProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Your Favorites";
        self.supportsInitialSearching = YES;
        
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    [[OPBackend shared] getItemsCreatedByUserWithQuery:queryString
                                        withPageNumber:pageNumber
                                               success:success
                                               failure:failure];
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    [self getItemsWithQuery:nil
             withPageNumber:nil
                    success:success
                    failure:failure];
}

@end
