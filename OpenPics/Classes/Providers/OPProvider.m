//
//  OPProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPProvider.h"
#import "AFJSONRequestOperation.h"

@implementation OPProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super init];
    if (self) {
        self.providerType = providerType;
        self.supportsLocationSearching = NO;
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
}

- (void) doInitialSearchWithCompletion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
}

- (void) getItemsWithRegion:(MKCoordinateRegion) region
                 completion:(void (^)(NSArray* items))completion {
    
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
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary* imageInfo = JSON[@"imageinfo"];
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
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"image info error: %@", error);
    }];
    [operation start];
}

@end
