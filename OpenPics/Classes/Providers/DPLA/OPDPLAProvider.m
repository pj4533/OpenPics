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

NSString * const OPProviderTypeDPLA = @"com.saygoodnight.dpla";

@implementation OPDPLAProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"Digital Public Library of America";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
    NSDictionary* parameters = @{
                                 @"q":queryString,
                                 @"sourceResource.date.before": @"1980",
//                                 @"hasView" : @"*image*",
                                 @"page_size" : @"50",
                                 @"page":pageNumber
                                 };
    

    NSLog(@"(DPLA GET) %@", parameters);
    
    [[AFDPLAClient sharedClient] getPath:@"items" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* resultArray = responseObject[@"docs"];
        NSMutableArray* retArray = [NSMutableArray array];
        for (NSDictionary* itemDict in resultArray) {
            
            NSURL* imageUrl = nil;
            NSString* urlString = itemDict[@"object"];
            
            // if we 'hasView' then we already have high res image
            id hasView = itemDict[@"hasView"];
            if (hasView) {
                if ([hasView isKindOfClass:[NSDictionary class]] ) {
                    NSString* mimeType = hasView[@"format"];
                    if (mimeType && [mimeType isEqualToString:@"application/pdf"]) {
                        urlString = nil;
                    } else
                        urlString = hasView[@"@id"];
                } else if ([hasView isKindOfClass:[NSArray class]]) {
                    NSDictionary* firstObject = hasView[0];
                    NSString* mimeType = firstObject[@"format"];
                    NSRange textRange;
                    textRange =[mimeType rangeOfString:@"image"];
                    if(textRange.location != NSNotFound) {
                        urlString = firstObject[@"url"];
                    }
                }
                
            }
//            else {
//                if (urlString) {
//                    // otherwise if we get here we have a thumbnail at least
//                    
//                    // check the provider
//                    NSDictionary* providerDict = itemDict[@"provider"];
//                    NSString* providerName = providerDict[@"name"];
//                    if ([providerName isEqualToString:@"Minnesota Digital Library"]) {
//                        urlString = [urlString stringByReplacingOccurrencesOfString:@"cgi-bin/thumbnail.exe" withString:@"utils/ajaxhelper/"];
//                        urlString = [urlString stringByAppendingString:@"&action=2&DMSCALE=25&DMWIDTH=2048&DMHEIGHT=2048"];
//                    } else if ([providerName isEqualToString:@"Digital Commonwealth"]) {
//                        NSString* isShownAt = itemDict[@"isShownAt"];
//                        NSString* lastPathComponent = [isShownAt lastPathComponent];
//                        NSArray* itemComponents = [lastPathComponent componentsSeparatedByString:@","];
//                        NSString* collectionString = itemComponents[0];
//                        NSString* fullItemString = [NSString stringWithFormat:@"%d",[itemComponents[1] integerValue] + 1];
//                        urlString = [NSString stringWithFormat:@"http://dlib.cwmars.org/cdm4/images/full_size/%@/%@.jpg", collectionString, fullItemString];
//                    } else if ([providerName isEqualToString:@"Mountain West Digital Library"]) {
//                        
//                        NSDictionary* originalRecord = itemDict[@"originalRecord"];
//                        NSDictionary* originalLinks = originalRecord[@"LINKS"];
//                        NSString* linkToRSRC = originalLinks[@"linktorsrc"];
//                        NSDictionary* sourceResourceDict = itemDict[@"sourceResource"];
//                        if (sourceResourceDict) {
//                            id type = sourceResourceDict[@"type"];
//                            if (type) {
//                                if ([type isKindOfClass:[NSString class]] && [type isEqualToString:@"text"]) {
//                                    
//                                } else {
//                                    NSURL* itemLinkUrl = [NSURL URLWithString:linkToRSRC];
//                                    NSString* lastPathComponent = [linkToRSRC lastPathComponent];
//                                    NSArray* itemComponents = [lastPathComponent componentsSeparatedByString:@","];
//                                    if (itemComponents.count == 2) {
//                                        NSString* collectionString = itemComponents[0];
//                                        NSString* idString = itemComponents[1];
//                                        NSString* hostName = itemLinkUrl.host;
//                                        
//                                        if ([hostName isEqualToString:@"digital.library.unlv.edu"]) {
//                                            urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
//                                            urlString = [urlString stringByAppendingString:@"&action=2&DMSCALE=25&DMWIDTH=2048&DMHEIGHT=2048"];
//                                        } else {
//                                            urlString = [NSString stringWithFormat:@"http://%@/utils/ajaxhelper/?CISOROOT=%@&CISOPTR=%@&action=2&DMSCALE=25&DMWIDTH=2048&DMHEIGHT=2048", hostName, collectionString,idString];
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    } else if ([providerName isEqualToString:@"University of Illinois at Urbana-Champaign"]) {
//                        urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
//                        urlString = [urlString stringByAppendingString:@"&action=2&DMWIDTH=2048&DMHEIGHT=2048"];
//                    }
//                    else {
//                        
//                     NSLog(@"%@", itemDict);
//                    }
//                }
//            }

            if (urlString) {
                NSLog(@"%@", urlString);
                imageUrl = [NSURL URLWithString:urlString];
            }
            NSString* titleString = @"";
            NSDictionary* sourceResourceDict = itemDict[@"sourceResource"];
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
            }
            if (imageUrl) {
                NSDictionary* opImageDict = @{@"imageUrl": imageUrl, @"title" : titleString};
                OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                [retArray addObject:item];
            }
        }
        
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

@end
