// OPBackend.m
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

#import "OPBackend.h"
#import "OPBackendKinvey.h"
#import "OPBackendTokens.h"
#import "OPImageItem.h"

@implementation OPBackend

+ (OPBackend *)shared {

    static OPBackend *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

#ifndef kOPBACKEND_KINVEY_APP_KEY
        _shared = [[OPBackend alloc] init];
        _shared.usingRemoteBackend = NO;
#else
        _shared = [[OPBackendKinvey alloc] init];
        _shared.usingRemoteBackend = YES;
#endif
        
        NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesFolder    = [pathList  objectAtIndex:0];
        NSString* favoritesPath = [cachesFolder stringByAppendingPathComponent:@"favorites"];
        _shared.itemsCreatedByUser = [NSKeyedUnarchiver unarchiveObjectWithFile:favoritesPath];
        if (!_shared.itemsCreatedByUser) {
            _shared.itemsCreatedByUser = [NSMutableArray array];
        }
    });
    
    return _shared;
}

- (void) saveItem:(OPImageItem*) item {
    [self.itemsCreatedByUser addObject:item];
    
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesFolder    = [pathList  objectAtIndex:0];
    NSString* favoritesPath = [cachesFolder stringByAppendingPathComponent:@"favorites"];
    [NSKeyedArchiver archiveRootObject:self.itemsCreatedByUser toFile:favoritesPath];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
}

- (void) getItemsCreatedByUserWithQuery:(NSString*) queryString
                         withPageNumber:(NSNumber*) pageNumber
                                success:(void (^)(NSArray* items, BOOL canLoadMore))success
                                failure:(void (^)(NSError* error))failure {
#warning ADD SEARCHING USING QUERY STRING HERE
    if (success) {
        success(self.itemsCreatedByUser, NO);
    }
}

- (BOOL) didUserCreateItem:(OPImageItem*) item {
    for (OPImageItem* thisItem in self.itemsCreatedByUser) {
        if ([item.imageUrl.absoluteString isEqualToString:thisItem.imageUrl.absoluteString]) {
            return YES;
        }
    }
    return NO;
}

@end
