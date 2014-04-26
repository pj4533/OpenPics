//
//  OPProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
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


#import "OPProvider.h"
#import "AFHTTPRequestOperation.h"

@implementation OPProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super init];
    if (self) {
        self.providerType = providerType;
        self.supportsInitialSearching = NO;
    }
    return self;
}

- (BOOL) isConfigured {
    return YES;
}

- (NSString*) providerShortName {
    if (!_providerShortName) {
        return self.providerName;
    }
    
    return _providerShortName;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
}

- (void) doInitialSearchWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {

}

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    [self upRezItem:item withCompletion:completion];
}

- (void) contentDMImageInfoWithURL:(NSURL*) url
                          withItem:(OPImageItem*) item
                      withHostName:(NSString*) hostName
                    withCollection:(NSString*) collectionString
                            withID:(NSString*) idString
                     withURLFormat:(NSString*) urlFormat
                    withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* imageInfo = responseObject[@"imageinfo"];
        if (imageInfo) {
            NSString* widthString = imageInfo[@"width"];
            NSString* heightString = imageInfo[@"height"];
            if (widthString && heightString) {
                NSInteger width = widthString.integerValue;
                NSInteger height = heightString.integerValue;
                
                NSString* scaledUrlString;
                CGFloat scalePercent = 100;
                if (width > height) {
                    if (width > 2048) {
                        scalePercent = (2048.0 / width) * 100.0;
                    }
                    scaledUrlString = [NSString stringWithFormat:urlFormat, hostName, collectionString,idString, scalePercent];
                } else {
                    if (height > 2048) {
                        scalePercent = (2048.0 / height) * 100.0;
                    }
                    scaledUrlString = [NSString stringWithFormat:urlFormat, hostName, collectionString,idString, scalePercent];
                }
                if (completion) {
                    completion([NSURL URLWithString:scaledUrlString], item);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"image info error: %@", error);
    }];
    [operation start];
}

@end
