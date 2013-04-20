//
//  OPEuropeanaProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/19/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPEuropeanaProvider.h"
#import "OPProviderTokens.h"
#import "AFEuropeanaClient.h"
#import "OPImageItem.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeEuropeana = @"com.saygoodnight.europeana";

@implementation OPEuropeanaProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Europeana";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    NSMutableDictionary* parameters = [@{
                                 @"query":queryString,
                                 @"rows" : @"50",
                                 @"qf" : @"image"
                                 } mutableCopy];
    
    NSNumber* startItem = @(((pageNumber.integerValue - 1) * 50) + 1);
    if (![pageNumber isEqualToNumber:@1]) {
        parameters[@"start"] = startItem;
    }

    [[AFEuropeanaClient sharedClient] getPath:@"search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray* resultArray = responseObject[@"items"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {

            NSArray* edmPreview = itemDict[@"edmPreview"];
            if (edmPreview && edmPreview.count) {
                NSString* urlString = edmPreview[0];
                NSURL* imageUrl = [NSURL URLWithString:urlString];
                NSString* titleString = @"";
                if (itemDict[@"title"]) {
                    NSArray* titleArray = itemDict[@"title"];
                    if (titleArray.count) {
                        titleString = titleArray[0];
                    }
                }
                NSDictionary* opImageDict = @{
                                              @"imageUrl": imageUrl,
                                              @"title" : titleString,
                                              @"providerSpecific" : @{
                                                        @"europeanaItem":itemDict[@"link"]
                                                      }
                                              };
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSString* itemsCount = responseObject[@"itemsCount"];
        NSString* totalResults = responseObject[@"totalResults"];
        if ((itemsCount.integerValue + startItem.integerValue) < totalResults.integerValue) {
            returnCanLoadMore = YES;
        }

        NSLog(@"COUNT: %@   TOTAL: %@", itemsCount, totalResults);
        if (completion) {
            completion(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl))completion {
    NSDictionary* providerSpecific = item.providerSpecific;
    NSString* europeanaItem = providerSpecific[@"europeanaItem"];
    NSURL* url = [NSURL URLWithString:europeanaItem];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString* urlString = item.imageUrl.absoluteString;
        NSDictionary* objectDict = JSON[@"object"];
        if (objectDict) {
            NSArray* aggregationsArray = objectDict[@"aggregations"];
            if (aggregationsArray && aggregationsArray.count) {
                NSDictionary* aggregationDict = aggregationsArray[0];
                NSDictionary* edmDataProviderDict = aggregationDict[@"edmDataProvider"];

                
                // Using edm DATA provider
                if (edmDataProviderDict) {
                    NSArray* defArray = edmDataProviderDict[@"def"];
                    if (defArray && defArray.count) {
                        NSString* dataProviderString = defArray[0];
                        
                        //
                        if ([dataProviderString isEqualToString:@"Kirklees Image Archive OAI Feed"]) {
                            NSLog(@"KNOWN: %@", dataProviderString);
                            NSArray* proxiesArray = objectDict[@"proxies"];
                            if (proxiesArray && proxiesArray.count) {
                                NSDictionary* proxyDict = proxiesArray[0];
                                NSDictionary* identifierDict = proxyDict[@"dcIdentifier"];
                                NSArray* defArray = identifierDict[@"def"];
                                if (defArray && defArray.count) {
                                    NSString* dcIdentifier = defArray[0];
                                    NSArray* semiComponents = [dcIdentifier componentsSeparatedByString:@";"];
                                    NSArray* ampComponents = [semiComponents.lastObject componentsSeparatedByString:@"&"];
                                    NSString* itemId = ampComponents[0];
                                    NSDictionary* identifierDict = proxyDict[@"dcSubject"];
                                    NSArray* defArray = identifierDict[@"def"];
                                    if (defArray && defArray.count) {
                                        NSString* dcSubject = defArray[0];
                                        if ([dcSubject isEqualToString:@"Kirklees"]) {
                                            urlString = [NSString stringWithFormat:@"https://www.hpacde.org.uk/kirklees/jpgh_kirklees/%@.jpg", itemId];
                                        } else if ([dcSubject isEqualToString:@"Bamforth"]) {
                                            urlString = [NSString stringWithFormat:@"https://www.hpacde.org.uk/kirklees/jpgh_bamforth/%@.jpg", itemId];                                            
                                        } else {
                                            NSLog(@"UNKNOWN SUBJECT: %@", dcSubject);
                                        }
                                    }
                                }
                            }
                        } else if ([dataProviderString isEqualToString:@"National Library of Wales"]) {
                            NSLog(@"KNOWN: %@", dataProviderString);
                            NSString* edmObject = aggregationDict[@"edmObject"];
                            if (edmObject) {
                                urlString = [edmObject stringByReplacingOccurrencesOfString:@"-13" withString:@"-11"];
                            } else {
                                NSLog(@"%@", objectDict);
                            }
                        
                        } else if ([dataProviderString isEqualToString:@"Leodis - A photographic archive of Leeds"]) {
                            NSLog(@"KNOWN: %@", dataProviderString);
                            NSArray* proxiesArray = objectDict[@"proxies"];
                            if (proxiesArray && proxiesArray.count) {
                                NSDictionary* proxyDict = proxiesArray[0];
                                NSDictionary* identifierDict = proxyDict[@"dcIdentifier"];
                                NSArray* defArray = identifierDict[@"def"];
                                if (defArray && defArray.count) {
                                    NSString* dcIdentifier = defArray[0];
                                    NSArray* equalsComponents = [dcIdentifier componentsSeparatedByString:@"="];
                                    NSString* itemId = equalsComponents[1];
                                    NSString* collectionId = [itemId substringFromIndex:itemId.length - 2];
                                    urlString = [NSString stringWithFormat:@"http://www.leodis.net/imagesLeodis/screen/%@/%@.jpg", collectionId, itemId];
                                }
                            }
                            
                        } else {
                            NSLog(@"UNKNOWN: %@", dataProviderString);
//                            NSLog(@"%@", objectDict);
                        }
                    }
                } else {
                    NSDictionary* edmProviderDict = aggregationDict[@"edmProvider"];
                    if (edmProviderDict) {
                        NSArray* defArray = edmProviderDict[@"def"];
                        if (defArray && defArray.count) {
                            NSString* providerString = defArray[0];
                            
                            NSLog(@"UNKNOWN PROVIDER: %@", providerString);
                        }
                    }
                }
            }
        }
        
        if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
            if (completion) {
                completion([NSURL URLWithString:urlString]);
            }
        }

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"image info error: %@", error);
    }];
    [operation start];
}

@end
