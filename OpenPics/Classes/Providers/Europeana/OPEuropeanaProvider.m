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
#import "NSDictionary+DefObject.h"
#import "TTTURLRequestFormatter.h"


NSString * const OPProviderTypeEuropeana = @"com.saygoodnight.europeana";

@implementation OPEuropeanaProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Europeana";
        self.supportsLocationSearching = YES;
    }
    return self;
}

- (void) getItemsWithRegion:(MKCoordinateRegion) region
                 completion:(void (^)(NSArray* items))completion {
    
    CLLocationCoordinate2D center = region.center;
    CLLocationCoordinate2D topLeft, bottomRight;
    topLeft.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    topLeft.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    bottomRight.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    bottomRight.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    NSString* latitudeParameter = [NSString stringWithFormat:@"pl_wgs84_pos_lat:[%f TO %f]", bottomRight.latitude, topLeft.latitude ];
    NSString* longitudeParameter = [NSString stringWithFormat:@"pl_wgs84_pos_long:[%f TO %f]", topLeft.longitude, bottomRight.longitude];
    
    NSDictionary* parameters = @{
                                 @"qf" : @[latitudeParameter,longitudeParameter,@"image"],
                                 @"rows" : @"100",
                                 @"query" : @"*:*"
                                 };
    
    NSLog(@"(EURO LOCATION GET) %@", parameters);

    [[AFEuropeanaClient sharedClient] getPath:@"search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", [TTTURLRequestFormatter cURLCommandFromURLRequest:operation.request]);
        NSArray* resultArray = responseObject[@"items"];
        NSArray* retArray = [self parseDocs:resultArray];
        
        if (completion) {
            completion(retArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
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

    NSLog(@"(EURO GET) %@", parameters);

    [[AFEuropeanaClient sharedClient] getPath:@"search.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray* resultArray = responseObject[@"items"];
        NSArray* retArray = [self parseDocs:resultArray];
        
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

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
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
                NSString* dataProviderString = [aggregationDict defObjectForKey:@"edmDataProvider"];
                
                
                if (dataProviderString) {
                    //
                    if (
                        ([dataProviderString isEqualToString:@"Kirklees Image Archive OAI Feed"]) ||
                        ([dataProviderString isEqualToString:@"Sheffield Images"])
                        )
                    {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        NSArray* proxiesArray = objectDict[@"proxies"];
                        if (proxiesArray && proxiesArray.count) {
                            NSDictionary* proxyDict = proxiesArray[0];
                            NSString* dcIdentifier = [proxyDict defObjectForKey:@"dcIdentifier"];
                            NSArray* semiComponents = [dcIdentifier componentsSeparatedByString:@";"];
                            NSArray* ampComponents = [semiComponents.lastObject componentsSeparatedByString:@"&"];
                            NSString* itemId = ampComponents[0];
                            NSString* dcSubject = [proxyDict defObjectForKey:@"dcSubject"];
                            if ([dataProviderString isEqualToString:@"Kirklees Image Archive OAI Feed"]) {
                                if ([dcSubject isEqualToString:@"Kirklees"]) {
                                    urlString = [NSString stringWithFormat:@"https://www.hpacde.org.uk/kirklees/jpgh_kirklees/%@.jpg", itemId];
                                } else if ([dcSubject isEqualToString:@"Bamforth"]) {
                                    urlString = [NSString stringWithFormat:@"https://www.hpacde.org.uk/kirklees/jpgh_bamforth/%@.jpg", itemId];
                                } else {
                                    NSLog(@"(Kirklees Image Archive OAI Feed) UNKNOWN SUBJECT: %@", dcSubject);
                                }
                            } else if ([dataProviderString isEqualToString:@"Sheffield Images"]) {
                                if ([dcSubject isEqualToString:@"Sheffield"]) {
                                    urlString = [NSString stringWithFormat:@"https://www.hpacde.org.uk/picturesheffield/jpgh_sheffield/%@.jpg", itemId];
                                } else {
                                    NSLog(@"(Sheffield Images) UNKNOWN SUBJECT: %@", dcSubject);
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
                            NSString* dcIdentifier = [proxyDict defObjectForKey:@"dcIdentifier"];
                            NSArray* equalsComponents = [dcIdentifier componentsSeparatedByString:@"="];
                            NSString* itemId = equalsComponents[1];
                            NSString* collectionId = [itemId substringFromIndex:itemId.length - 2];
                            urlString = [NSString stringWithFormat:@"http://www.leodis.net/imagesLeodis/screen/%@/%@.jpg", collectionId, itemId];
                        }
                        
                    } else if ([dataProviderString isEqualToString:@"National Library of the Netherlands - Koninklijke Bibliotheek"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        NSString* edmObject = aggregationDict[@"edmObject"];
                        if (edmObject) {
                            urlString = [edmObject stringByReplacingOccurrencesOfString:@"role=thumbnail" withString:@"size=large"];
                        } else {
                            NSLog(@"%@", objectDict);
                        }
                    } else if ([dataProviderString isEqualToString:@"Fundación Albéniz"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        NSArray* proxiesArray = objectDict[@"proxies"];
                        if (proxiesArray && proxiesArray.count) {
                            NSDictionary* proxyDict = proxiesArray[0];
                            NSString* dcIdentifier = [proxyDict defObjectForKey:@"dcIdentifier"];
                            if (dcIdentifier) {
                                urlString = [NSString stringWithFormat:@"http://www.classicalplanet.com/documentViewer.xhtml?id=2&tipo=3&archivo=%@&ruta=",dcIdentifier];
                            }
                        }
                        
                    } else if ([dataProviderString isEqualToString:@"Nationaal Archief"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        // EWWWWWWWWWWW scrape-a-delic
                        NSString* edmIsShownAt = aggregationDict[@"edmIsShownAt"];
                        NSURL* url = [NSURL URLWithString:edmIsShownAt];
                        NSURLRequest *subrequest = [NSURLRequest requestWithURL:url];
                        AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:subrequest];
                        [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            
                            NSArray* bigpicComponents = [webpageHTML componentsSeparatedByString:@"\" class=\"bigPicture\""];
                            if (bigpicComponents && bigpicComponents.count) {
                                NSArray* quotesComponents = [bigpicComponents[0] componentsSeparatedByString:@"\""];
                                if (quotesComponents && quotesComponents.count) {
                                    if (completion) {
                                        
                                        NSString* bigpicUrlString = quotesComponents.lastObject;
                                        bigpicUrlString = [bigpicUrlString stringByReplacingOccurrencesOfString:@"1280x1280" withString:@"800x600"];
                                        completion([NSURL URLWithString:bigpicUrlString],item);
                                    }
                                }
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"%@", error);
                        }];
                        [httpOperation start];
                        
                    } else if ([dataProviderString isEqualToString:@"The Wellcome Library"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        // EWWWWWWWWWWW more scrape-a-delic
                        NSArray* proxiesArray = objectDict[@"proxies"];
                        if (proxiesArray && proxiesArray.count) {
                            NSDictionary* proxyDict = proxiesArray[0];
                            NSString* dcSource = [proxyDict defObjectForKey:@"dcSource"];
                            NSString* htmlFrameUrlString = [NSString stringWithFormat:@"http://wellcomeimages.org/indexplus/image/result.html?*sform=wellcome-images&_IXACTION_=query&_IXFIRST_=1&%%3did_ref=%@&_IXSPFX_=templates/t&_IXFPFX_=templates/t&_IXMAXHITS_=1&", dcSource];
                            
                            NSURL* url = [NSURL URLWithString:htmlFrameUrlString];
                            NSURLRequest *subrequest = [NSURLRequest requestWithURL:url];
                            AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:subrequest];
                            [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                NSString* separatorString = [NSString stringWithFormat:@"\" border=\"0\" alt=\"%@", item.title];
                                NSArray* components = [webpageHTML componentsSeparatedByString:separatorString];
                                if (components && components.count) {
                                    NSArray* quotesComponents = [components[0] componentsSeparatedByString:@"\""];
                                    if (quotesComponents && quotesComponents.count) {
                                        NSString* finalUprezedUrlString = [NSString stringWithFormat:@"http://wellcomeimages.org/indexplus/%@", quotesComponents.lastObject];
                                        if (completion) {
                                            completion([NSURL URLWithString:finalUprezedUrlString],item);
                                        }
                                    }
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
                            [httpOperation start];
                        }
                    } else if ([dataProviderString isEqualToString:@"Durham county council"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        // EWWWWWWWWWWW more scrape-a-delic
                        NSArray* proxiesArray = objectDict[@"proxies"];
                        if (proxiesArray && proxiesArray.count) {
                            NSDictionary* proxyDict = proxiesArray[0];
                            NSString* dcIdentifier = [proxyDict defObjectForKey:@"dcIdentifier"];
                            NSString* htmlURLString = [NSString stringWithFormat:@"%@&PIC=Y", dcIdentifier];
                            
                            NSURL* url = [NSURL URLWithString:htmlURLString];
                            NSURLRequest *subrequest = [NSURLRequest requestWithURL:url];
                            AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:subrequest];
                            [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                NSString* separatorString = [NSString stringWithFormat:@"\" alt=\"%@", item.title];
                                NSArray* components = [webpageHTML componentsSeparatedByString:separatorString];
                                if (components && components.count) {
                                    NSArray* quotesComponents = [components[0] componentsSeparatedByString:@"\""];
                                    if (quotesComponents && quotesComponents.count) {
                                        if (completion) {
                                            completion([NSURL URLWithString:quotesComponents.lastObject],item);
                                        }
                                    }
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
                            [httpOperation start];
                        }
                    } else if ([dataProviderString isEqualToString:@"English Heritage - Viewfinder"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        // EWWWWWWWWWWW more scrape-a-delic
                        NSArray* proxiesArray = objectDict[@"proxies"];
                        if (proxiesArray && proxiesArray.count) {
                            NSDictionary* proxyDict = proxiesArray[0];
                            NSString* dcIdentifier = [proxyDict defObjectForKey:@"dcIdentifier"];
                            
                            NSURL* url = [NSURL URLWithString:dcIdentifier];
                            NSURLRequest *subrequest = [NSURLRequest requestWithURL:url];
                            AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:subrequest];
                            [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                NSString* separatorString = @"\" border='0' class='vfImage' alt=\"";
                                NSArray* components = [webpageHTML componentsSeparatedByString:separatorString];
                                if (components && components.count) {
                                    NSArray* quotesComponents = [components[0] componentsSeparatedByString:@"\""];
                                    if (quotesComponents && quotesComponents.count) {
                                        if (completion) {
                                            completion([NSURL URLWithString:quotesComponents.lastObject],item);
                                        }
                                    }
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
                            [httpOperation start];
                        }
                    } else if ([dataProviderString isEqualToString:@"Deutsches Filminstitut - DIF"]) {
                        NSLog(@"KNOWN: %@", dataProviderString);
                        urlString = aggregationDict[@"edmIsShownBy"];
                    } else {
                        NSLog(@"UNKNOWN: %@", dataProviderString);
                        //NSLog(@"%@", JSON);
                    }
                    
                } else {
                    NSString* edmProvider = [aggregationDict defObjectForKey:@"edmProvider"];
                    NSLog(@"UNKNOWN PROVIDER: %@", edmProvider);
                }
            }
        }
        
        if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
            if (completion) {
                completion([NSURL URLWithString:urlString],item);
            }
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"image info error: %@", error);
    }];
    [operation start];
}

#pragma mark - Utilities

- (NSArray*) parseDocs:(NSArray*) resultArray {
    NSMutableArray* retArray = [NSMutableArray array];
    for (NSDictionary* itemDict in resultArray) {
        
        NSArray* edmPreview = itemDict[@"edmPreview"];
        if (edmPreview && edmPreview.count) {
            NSString* urlString = edmPreview[0];
            NSURL* imageUrl = [NSURL URLWithString:urlString];
            NSString* titleString = @"";
            NSString* latitude = nil;
            NSString* longitude = nil;

            if (itemDict[@"title"]) {
                NSArray* titleArray = itemDict[@"title"];
                if (titleArray.count) {
                    titleString = titleArray[0];
                }
            }
            
            NSMutableDictionary* opImageDict = [@{
                                          @"imageUrl": imageUrl,
                                          @"title" : titleString,
                                          @"providerSpecific" : @{
                                                  @"europeanaItem":itemDict[@"link"]
                                                  }
                                          } mutableCopy];
            
            if (itemDict[@"edmPlaceLatitude"]) {
                if ([itemDict[@"edmPlaceLatitude"] isKindOfClass:[NSArray class]]) {
                    NSArray* placeLatitude = itemDict[@"edmPlaceLatitude"];
                    for (NSString* thisLat in placeLatitude) {
                        if (![thisLat isEqualToString:@"0.0"]) {
                            latitude = thisLat;
                        }
                    }
                }
            }
            if (itemDict[@"edmPlaceLongitude"]) {
                if ([itemDict[@"edmPlaceLongitude"] isKindOfClass:[NSArray class]]) {
                    NSArray* placeLongitude = itemDict[@"edmPlaceLongitude"];
                    for (NSString* thisLong in placeLongitude) {
                        if (![thisLong isEqualToString:@"0.0"]) {
                            longitude = thisLong;
                        }
                    }
                }
            }

            if (latitude && longitude) {
                opImageDict[@"latitude"] = latitude;
                opImageDict[@"longitude"] = longitude;
            }

            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
            [retArray addObject:item];
        }
    }

    return retArray;
}


@end
