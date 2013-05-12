//
//  OPCDLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/10/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPCDLProvider.h"
#import "AFCDLClient.h"
#import "OPImageItem.h"
#import "AFKissXMLRequestOperation.h"

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
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
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

//    NSLog(@"(CDL GET) %@", parameters);
    
    [[AFCDLClient sharedClient] getPath:@"search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        AFKissXMLRequestOperation* kissXMLOperation = (AFKissXMLRequestOperation*) operation;
        
        if ([kissXMLOperation.responseXMLDocument isKindOfClass:[DDXMLDocument class]]) {
            NSError *error;
            
            NSMutableArray* retArray = [NSMutableArray array];
            BOOL returnCanLoadMore = NO;
            
            NSArray *facetGroups = [kissXMLOperation.responseXMLDocument nodesForXPath:@"crossQueryResult/facet/group" error:&error];
            for (DDXMLElement* groupElement in facetGroups) {
                NSString* groupName = [[groupElement attributeForName:@"value"] stringValue];
                if ([groupName isEqualToString:@"image"]) {
                    NSString* totalDocs = [[groupElement attributeForName:@"totalDocs"] stringValue];
                    NSString* endDoc = [[groupElement attributeForName:@"endDoc"] stringValue];
                    
//                    NSLog(@"TOTAL: %@   END: %@", totalDocs, endDoc);

                    NSArray* docHits = [groupElement nodesForXPath:@"docHit" error:&error];
                    for (DDXMLElement* itemElement in docHits) {
                        DDXMLElement *metaElement = [[itemElement nodesForXPath:@"meta" error:&error] objectAtIndex:0];
                        NSArray* typeNodes = [metaElement nodesForXPath:@"type" error:&error];
                        if (typeNodes.count) {
                            DDXMLElement *typeElement = typeNodes[0];
                            
                            if ([typeElement.stringValue.lowercaseString isEqualToString:@"image"] || [typeElement.stringValue.lowercaseString isEqualToString:@"image collection"]) {
                                NSArray* elementArray = [metaElement nodesForXPath:@"reference-image" error:&error];
                                NSString* imagePath = @"";
                                if (elementArray.count) {
                                    
                                    DDXMLElement *referenceImage = elementArray[0];
                                    NSString* srcString = [[referenceImage attributeForName:@"src"] stringValue];
                                    imagePath = [NSString stringWithFormat:@"http://content.cdlib.org%@", srcString];
                                    
                                    NSURL* imageUrl = [NSURL URLWithString:imagePath];
                                    NSString* titleString = @"";
                                    NSArray* titleNodes = [metaElement nodesForXPath:@"title" error:&error];
                                    if (titleNodes.count) {
                                        titleString = [titleNodes[0] stringValue];
                                    }
                                    
                                    NSDictionary* opImageDict = @{@"imageUrl": imageUrl, @"title" : titleString};
                                    OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                                    [retArray addObject:item];
                                }
                                
                            }
                        }                        
                    }
                    if (endDoc.integerValue < totalDocs.integerValue) {
                        returnCanLoadMore = YES;
                    }
                }
                
            }
            
            if (completion) {
                completion(retArray,returnCanLoadMore);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

@end
