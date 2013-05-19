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
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

    if (providerSpecific[@"refimage"]) {
        urlString = providerSpecific[@"refimage"];
    }

    if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
        if (completion) {
            completion([NSURL URLWithString:urlString], item);
        }
    }
}

@end
