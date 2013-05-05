//
//  OPDPLAProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPDPLAProvider.h"
#import "OPImageItem.h"
#import "AFDPLAClient.h"
#import "TTTURLRequestFormatter.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeDPLA = @"com.saygoodnight.dpla";

@implementation OPDPLAProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Digital Public Library of America";
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
    
    NSString* boundingBoxString = [NSString stringWithFormat:@"%f,%f:%f,%f", topLeft.latitude,topLeft.longitude,bottomRight.latitude,bottomRight.longitude];

    NSDictionary* parameters = @{
                                 @"sourceResource.spatial.coordinates" : boundingBoxString,
                                 @"sourceResource.type" : @"*image* OR *Image*",
                                 @"page_size" : @"100"
                                 };
    
    NSLog(@"(DPLA GET) %@", parameters);
    
    [[AFDPLAClient sharedClient] getPath:@"items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* resultArray = responseObject[@"docs"];
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
    
    NSDictionary* parameters = @{
                                 @"q":queryString,
                                 @"sourceResource.date.before": @"1980",
                                 @"sourceResource.type" : @"*image* OR *Image*",
                                 @"page_size" : @"50",
                                 @"page":pageNumber
                                 };
    

    NSLog(@"(DPLA GET) %@", parameters);
    
    [[AFDPLAClient sharedClient] getPath:@"items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray* resultArray = responseObject[@"docs"];
        NSArray* retArray = [self parseDocs:resultArray];
        
        BOOL returnCanLoadMore = NO;
        NSInteger startItem = [responseObject[@"start"] integerValue];
        NSInteger lastItem = startItem + resultArray.count;
        NSInteger totalItems = [responseObject[@"count"] integerValue];
        if (lastItem < totalItems) {
            returnCanLoadMore = YES;
        }
        
        NSLog(@"LAST: %d   TOTAL: %d", lastItem, totalItems);
        if (completion) {
            completion(retArray, returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}


// Nothing to see here....please move along
- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {

    NSDictionary* providerSpecific = item.providerSpecific;
    NSString* urlString = item.imageUrl.absoluteString;
    
    
    if (providerSpecific[@"dplaHasView"]) {
        urlString = providerSpecific[@"dplaHasView"];
    }

    NSString* providerName = providerSpecific[@"dplaProviderName"];
    //    NSLog(@"%@", item.imageUrl.absoluteString);
    //    NSLog(@"%@", providerSpecific);
    
    if ([providerName isEqualToString:@"Minnesota Digital Library"]) {
        NSLog(@"KNOWN: %@", providerName);
        NSURL* itemLinkUrl = [NSURL URLWithString:providerSpecific[@"dplaIsShownAt"]];
        NSArray* paramsComponents = [providerSpecific[@"dplaIsShownAt"] componentsSeparatedByString:@"?/"];
        NSArray* itemComponents = [paramsComponents[1] componentsSeparatedByString:@","];
        if (itemComponents.count == 2) {
            NSString* collectionString = itemComponents[0];
            NSString* idString = itemComponents[1];
            NSString* hostName = itemLinkUrl.host;
            
            NSString* imageInfoUrlString = [NSString stringWithFormat:@"http://%@/utils/ajaxhelper/?CISOROOT=%@&CISOPTR=%@&action=1", hostName, collectionString,idString];
            NSURL *url = [NSURL URLWithString:imageInfoUrlString];
            NSString* urlFormat = @"http://%@/utils/ajaxhelper/?CISOROOT=%@&CISOPTR=%@&action=2&DMSCALE=%f&DMWIDTH=2048&DMHEIGHT=2048";
            [self contentDMImageInfoWithURL:url withItem:item withHostName:hostName withCollection:collectionString withID:idString withURLFormat:urlFormat withCompletion:completion];
        }
    } else if ([providerName isEqualToString:@"Digital Library of Georgia"]) {
        NSLog(@"KNOWN: %@", providerName);
        NSDictionary* originalRecord = providerSpecific[@"dplaOriginalRecord"];
        NSString* originalId = originalRecord[@"id"];
        NSArray* colonComponents = [originalId componentsSeparatedByString:@":"];
        NSString* idComponent = colonComponents[2];
        NSArray* underscoreComponents = [idComponent componentsSeparatedByString:@"_"];
        
        NSString* collectionCode = underscoreComponents[1];
        NSString* idCode = underscoreComponents[2];
        
        // this 'lev' thing appears to control the size of the image 1 being highest rez
        if ([collectionCode isEqualToString:@"vang"]) {
            NSString* vanCollection = [idCode substringToIndex:3];
            urlString = [NSString stringWithFormat:@"http://128.192.128.20/lizardtech/iserv/getimage?cat=vanga&item=/%@/sid/%@.sid&lev=2",vanCollection,idCode];
        } else if ( [collectionCode isEqualToString:@"anac"]) {
            urlString = [NSString stringWithFormat:@"http://128.192.128.20/lizardtech/iserv/getimage?cat=%@&item=/sids/%@.sid&lev=2", underscoreComponents[0],idCode];
        } else if ([collectionCode isEqualToString:@"larc"]) {
            urlString = [NSString stringWithFormat:@"http://dbs.galib.uga.edu/larc/photos/%@.jpg",idCode];
        } else {
            urlString = [NSString stringWithFormat:@"http://128.192.128.20/lizardtech/iserv/getimage?cat=%@&item=%@.sid&lev=2", collectionCode, idCode];
        }
        
    } else if ([providerName isEqualToString:@"Digital Commonwealth"]) {
        NSLog(@"KNOWN: %@", providerName);
        NSString* isShownAt = providerSpecific[@"dplaIsShownAt"];
        NSString* lastPathComponent = [isShownAt lastPathComponent];
        NSArray* itemComponents = [lastPathComponent componentsSeparatedByString:@","];
        NSString* collectionString = itemComponents[0];
        NSString* fullItemString = [NSString stringWithFormat:@"%d",[itemComponents[1] integerValue] + 1];
        urlString = [NSString stringWithFormat:@"http://dlib.cwmars.org/cdm4/images/full_size/%@/%@.jpg", collectionString, fullItemString];
    } else if ([providerName isEqualToString:@"Mountain West Digital Library"]) {
        NSLog(@"KNOWN: %@", providerName);
        NSDictionary* originalRecord = providerSpecific[@"dplaOriginalRecord"];
        NSDictionary* originalLinks = originalRecord[@"LINKS"];
        NSString* linkToRSRC = originalLinks[@"linktorsrc"];
        id type = providerSpecific[@"dplaSourceResourceType"];
        if (type) {
            if ([type isKindOfClass:[NSString class]] && [type isEqualToString:@"text"]) {
                
            } else {
                NSURL* itemLinkUrl = [NSURL URLWithString:linkToRSRC];
                NSString* lastPathComponent = [linkToRSRC lastPathComponent];
                NSArray* itemComponents = [lastPathComponent componentsSeparatedByString:@","];
                if (itemComponents.count == 2) {
                    NSString* collectionString = itemComponents[0];
                    NSString* idString = itemComponents[1];
                    NSString* hostName = itemLinkUrl.host;
                    
                    if ([hostName isEqualToString:@"digital.library.unlv.edu"]) {
                        // TODO: figure out contentDM version 5 - how to get image info?
                        urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
                        urlString = [urlString stringByAppendingString:@"&action=2&DMSCALE=25&DMWIDTH=2048&DMHEIGHT=2048"];
                    } else {
                        
                        NSString* imageInfoUrlString = [NSString stringWithFormat:@"http://%@/utils/ajaxhelper/?CISOROOT=%@&CISOPTR=%@&action=1", hostName, collectionString,idString];
                        NSURL *url = [NSURL URLWithString:imageInfoUrlString];
                        NSString* urlFormat = @"http://%@/utils/ajaxhelper/?CISOROOT=%@&CISOPTR=%@&action=2&DMSCALE=%f&DMWIDTH=2048&DMHEIGHT=2048&DMX=0&DMY=0&DMROTATE=0&DMTEXT=";
                        [self contentDMImageInfoWithURL:url withItem:item withHostName:hostName withCollection:collectionString withID:idString withURLFormat:urlFormat withCompletion:completion];
                    }
                }
            }
        }
    } else if ([providerName isEqualToString:@"University of Illinois at Urbana-Champaign"]) {
        NSLog(@"KNOWN: %@", providerName);
        urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
        urlString = [urlString stringByAppendingString:@"&DMSCALE=50&DMWIDTH=2048&DMHEIGHT=2048"];
    } else if ([providerName isEqualToString:@"National Archives and Records Administration"]) {
        NSLog(@"KNOWN: %@ (no uprez)", providerName);
    } else {
        NSLog(@"UNKNOWN: %@", providerName);
    }

    if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
        if (completion) {
            completion([NSURL URLWithString:urlString],item);
        }
    }

}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    
    NSDictionary* providerSpecific = item.providerSpecific;
    NSString* urlString = item.imageUrl.absoluteString;
    
    if (providerSpecific[@"dplaHasView"]) {
        urlString = providerSpecific[@"dplaHasView"];
    }
    
    if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
        if (completion) {
            completion([NSURL URLWithString:urlString], item);
        }
    }
}

#pragma mark - Utilities

- (NSArray*) parseDocs:(NSArray*) resultArray {
    NSMutableArray* retArray = [NSMutableArray array];
    for (NSDictionary* itemDict in resultArray) {
        
        NSURL* imageUrl = nil;
        NSMutableDictionary* providerSpecific = [NSMutableDictionary dictionary];
        
        // Maybe by default put entire record inside here?
        
        // DPLA provider name
        NSDictionary* providerDict = itemDict[@"provider"];
        NSString* providerName = providerDict[@"name"];
        providerSpecific[@"dplaProviderName"] = providerName;
        
        // DPLA is shown at
        NSString* isShownAt = itemDict[@"isShownAt"];
        providerSpecific[@"dplaIsShownAt"] = isShownAt;
        
        // DPLA original record dict
        NSDictionary* originalRecord = itemDict[@"originalRecord"];
        providerSpecific[@"dplaOriginalRecord"] = originalRecord;
        
        // DPLA source resource
        NSDictionary* sourceResourceDict = itemDict[@"sourceResource"];
        if (sourceResourceDict) {
            id type = sourceResourceDict[@"type"];
            if (type)
                providerSpecific[@"dplaSourceResourceType"] = type;
        }
        
        NSString* urlString = itemDict[@"object"];
        
        // if we 'hasView' then we already have high res image
        id hasView = itemDict[@"hasView"];
        if (hasView) {
            if ([hasView isKindOfClass:[NSDictionary class]] ) {
                NSString* mimeType = hasView[@"format"];
                if (mimeType && ![mimeType isKindOfClass:[NSNull class]]) {
                    if ([mimeType isEqualToString:@"application/pdf"]) {
                        urlString = nil;
                    } else {
                        providerSpecific[@"dplaHasView"] = hasView[@"@id"];
                    }
                }
            } else if ([hasView isKindOfClass:[NSArray class]]) {
                NSDictionary* firstObject = hasView[0];
                NSString* mimeType = firstObject[@"format"];
                NSRange textRange;
                textRange =[mimeType rangeOfString:@"image"];
                if(textRange.location != NSNotFound) {
                    providerSpecific[@"dplaHasView"] = firstObject[@"url"];
                }
            }
            
        }
        
        if (urlString) {
            imageUrl = [NSURL URLWithString:urlString];
        }
        
        NSString* titleString = @"";
        NSString* latitude = nil;
        NSString* longitude = nil;
        if (sourceResourceDict) {
            id title = sourceResourceDict[@"title"];
            
            if (title) {
                if ([title isKindOfClass:[NSArray class]]) {
                    titleString = [title componentsJoinedByString:@", "];
                } else if ([title isKindOfClass:[NSString class]])
                    titleString = title;
                else
                    NSLog(@"ERROR TITLE IS: %@", [title class]);
            }
            
            id spatial = sourceResourceDict[@"spatial"];
            
            if (spatial) {
                if ([spatial isKindOfClass:[NSArray class]]) {
                    NSString* coordinates = spatial[0][@"coordinates"];
                    if (coordinates) {
                        NSArray* commaComponents = [coordinates componentsSeparatedByString:@", "];
                        latitude = commaComponents[0];
                        longitude = commaComponents[1];
                    }
                } else if ([spatial isKindOfClass:[NSDictionary class]]) {
                    NSString* coordinates = spatial[@"coordinates"];
                    if (coordinates) {
                        NSArray* commaComponents = [coordinates componentsSeparatedByString:@", "];
                        latitude = commaComponents[0];
                        longitude = commaComponents[1];
                    }
                } else
                    NSLog(@"ERROR SPATIAL IS: %@", [spatial class]);
            }
        }
        if (imageUrl) {
            NSMutableDictionary* opImageDict = [@{
                                          @"imageUrl": imageUrl,
                                          @"title" : titleString,
                                          @"providerSpecific" : providerSpecific,
                                          } mutableCopy];
            
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
