//
//  OPCDLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/10/13.
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


#import "OPCDLProvider.h"
#import "AFCDLSessionManager.h"
#import "OPImageItem.h"
#import "DDXML.h"

NSString * const OPProviderTypeCDL = @"com.saygoodnight.cdl";

@implementation OPCDLProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"California Digital Library";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    NSMutableDictionary* parameters = [@{
                                 @"keyword" : queryString,
                                 @"style" : @"cui",
                                 @"facet" : @"type-tab",
                                 @"group" : @"image",
                                 @"raw" : @"1"
                                 } mutableCopy];

    if (![pageNumber isEqualToNumber:@1]) {
        NSNumber* startDoc = @(((pageNumber.integerValue - 1) * 25) + 1);
        parameters[@"startDoc"] = startDoc;
    }

    [[AFCDLSessionManager sharedClient] GET:@"search" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString* responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSError* error;
        
        DDXMLDocument* document = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:&error];
        
        NSMutableArray* retArray = [NSMutableArray array];
        BOOL returnCanLoadMore = NO;
        
        NSArray *facetGroups = [document nodesForXPath:@"crossQueryResult/facet/group" error:&error];
        for (DDXMLElement* groupElement in facetGroups) {
            NSString* groupName = [[groupElement attributeForName:@"value"] stringValue];
            if ([groupName isEqualToString:@"image"]) {
                NSString* totalDocs = [[groupElement attributeForName:@"totalDocs"] stringValue];
                NSString* endDoc = [[groupElement attributeForName:@"endDoc"] stringValue];
                
                NSLog(@"TOTAL: %@   END: %@", totalDocs, endDoc);
                
                NSArray* docHits = [groupElement nodesForXPath:@"docHit" error:&error];
                for (DDXMLElement* itemElement in docHits) {
                    
                    NSString* path = [[itemElement attributeForName:@"path"] stringValue];
                    NSArray* dotComponents  = [path componentsSeparatedByString:@"."];
                    NSArray* colonComponents = [dotComponents[0] componentsSeparatedByString:@":"];
                    NSString* pathString = colonComponents[1];
                    NSString* imageId = pathString.lastPathComponent;
                    NSString* noLastPathComponent = [pathString stringByDeletingLastPathComponent];
                    NSString* urlString = [NSString stringWithFormat:@"http://imgzoom.cdlib.org/Converter?id=/%@/files/%@-z1.jp2&w=300",noLastPathComponent,imageId];
                    
                    DDXMLElement *metaElement = [[itemElement nodesForXPath:@"meta" error:&error] objectAtIndex:0];
                    NSString* titleString = @"";
                    NSArray* titleNodes = [metaElement nodesForXPath:@"title" error:&error];
                    if (titleNodes.count) {
                        titleString = [titleNodes[0] stringValue];
                    }
                    
                    NSMutableDictionary* providerSpecific = [NSMutableDictionary dictionary];
                    
                    NSArray* referenceImages = [metaElement nodesForXPath:@"reference-image" error:&error];
                    if (referenceImages.count) {
                        NSString* src = [[referenceImages[0] attributeForName:@"src"] stringValue];
                        urlString = [NSString stringWithFormat:@"http://content.cdlib.org%@", src];
                        
                        if (referenceImages.count > 1) {
                            NSString* higherResRefImage = [NSString stringWithFormat:@"http://content.cdlib.org%@", [[referenceImages.lastObject attributeForName:@"src"] stringValue]];
                            providerSpecific[@"refimage"] = higherResRefImage;
                        }
                    }
                    
                    NSURL* imageUrl = [NSURL URLWithString:urlString];
                    NSDictionary* opImageDict = @{
                                                  @"imageUrl": imageUrl,
                                                  @"title" : titleString,
                                                  @"providerType": self.providerType
                                                  };
                    OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                    [retArray addObject:item];
                }
                if (endDoc.integerValue < totalDocs.integerValue) {
                    returnCanLoadMore = YES;
                }
            }
            
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

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    
    NSString* urlString = item.imageUrl.absoluteString;
    NSDictionary* providerSpecific = item.providerSpecific;

    urlString = [urlString stringByReplacingOccurrencesOfString:@"w=300" withString:@"w=1200"];

    if (![providerSpecific isKindOfClass:[NSNull class]] && providerSpecific[@"refimage"]) {
        urlString = providerSpecific[@"refimage"];
    }

    if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
        if (completion) {
            completion([NSURL URLWithString:urlString], item);
        }
    }
}

@end
