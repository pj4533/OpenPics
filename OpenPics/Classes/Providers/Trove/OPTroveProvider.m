// OPTroveProvider.m
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

#import "OPTroveProvider.h"
#import "OPImageItem.h"
#import "AFTroveSessionManager.h"
#import "OPProviderTokens.h"
#import "AFHTTPRequestOperation.h"

NSString * const OPProviderTypeTrove = @"com.saygoodnight.trove";

@implementation OPTroveProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"National Library of Australia - Trove";
    }
    return self;
}

- (BOOL) isConfigured {
#ifndef kOPPROVIDERTOKEN_TROVE
#warning *** WARNING: Make sure you have added your Trove token to OPProviderTokens.h!
    return NO;
#else
    return YES;
#endif
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    NSDictionary* parameters = @{
                                 @"q":queryString,
                                 @"reclevel": @"full",
                                 @"zone": @"picture",
                                 @"encoding": @"json",
                                 @"l-availability": @"y/f",
                                 @"l-australian": @"y",
                                 @"include": @"holdings,links,subscribinglibs,workversions",
                                 @"s":[NSString stringWithFormat:@"%d", (pageNumber.integerValue - 1) * 20]
                                 };
    
    
    NSLog(@"(Trove GET) %@", parameters);
    
    [[AFTroveSessionManager sharedClient] GET:@"result" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary* responseDict = responseObject[@"response"];
        NSArray* zoneArray = responseDict[@"zone"];
        NSDictionary* pictureZone = zoneArray[0];
        NSDictionary* recordsDict = pictureZone[@"records"];
        NSArray* resultArray = recordsDict[@"work"];
        
        NSMutableArray* retArray = [NSMutableArray array];
        if (resultArray) {
            for (NSDictionary* itemDict in resultArray) {
                
                NSMutableDictionary* providerSpecific = [NSMutableDictionary dictionary];
                
                NSString* troveUrlString = itemDict[@"troveUrl"];
                NSURL* troveUrl = nil;
                if (troveUrlString) {
                    troveUrl = [NSURL URLWithString:troveUrlString];
                }
                
                NSArray* holdingArray = itemDict[@"holding"];
                if (holdingArray.count) {
                    NSDictionary* holdingDict = holdingArray[0];
                    NSString* holdingName = holdingDict[@"name"];
                    if (holdingName) {
                        providerSpecific[@"troveHoldingName"] = holdingName;
                    }
                    NSString* holdingNUC = holdingDict[@"nuc"];
                    if (holdingNUC) {
                        providerSpecific[@"troveHoldingNUC"] = holdingNUC;
                    }
                    
                    NSDictionary* holdingUrl = holdingDict[@"url"];
                    if (holdingUrl) {
                        if (holdingUrl[@"value"]) {
                            providerSpecific[@"troveHoldingValue"] = holdingUrl[@"value"];
                        }
                    }
                }
                
                NSArray* identifierArray = itemDict[@"identifier"];
                if (identifierArray) {
                    
                    NSURL* imageUrl = [NSURL URLWithString:@""];
                    for (NSDictionary* identifierDict in identifierArray) {
                        
                        if ([identifierDict[@"linktype"] isEqualToString:@"thumbnail"]) {
                            NSString* urlString = [identifierDict[@"value"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            imageUrl = [NSURL URLWithString:urlString];
                        }
                    }
                    
                    NSString* titleString = @"";
                    if (itemDict[@"title"]) {
                        titleString = itemDict[@"title"];
                    }
                    if (itemDict[@"snippet"]) {
                        titleString = itemDict[@"snippet"];
                    }
                    
                    if (itemDict[@"troveUrl"]) {
                        providerSpecific[@"troveUrl"] = itemDict[@"troveUrl"];
                    }
                    
                    titleString = [titleString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                    titleString = [titleString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
                    titleString = [titleString stringByReplacingOccurrencesOfString:@"<i>" withString:@""];
                    titleString = [titleString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
                    
                    NSDictionary* opImageDict = @{
                                                  @"imageUrl": imageUrl,
                                                  @"title" : titleString,
                                                  @"providerSpecific" : providerSpecific,
                                                  @"providerType": self.providerType,
                                                  @"providerUrl": troveUrl
                                                  };
                    OPImageItem* item = [[OPImageItem alloc] initWithDictionary:opImageDict];
                    [retArray addObject:item];
                }
            }
        }
        
        BOOL returnCanLoadMore = NO;
        NSInteger startItem = [recordsDict[@"s"] integerValue];
        NSInteger lastItem = startItem + 20;
        NSInteger totalItems = [recordsDict[@"total"] integerValue];
        if (lastItem < totalItems) {
            returnCanLoadMore = YES;
        }
        
        NSLog(@"LAST: %ld   TOTAL: %ld", (long)lastItem, (long)totalItems);
        if (success) {
            success(retArray, returnCanLoadMore);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) fullUpRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    
    NSDictionary* providerSpecific = item.providerSpecific;
    NSString* urlString = item.imageUrl.absoluteString;
    
    NSString* providerName = providerSpecific[@"troveHoldingName"];
    
    if (!providerSpecific[@"troveHoldingName"]) {
        NSLog(@"KNOWN: No Provider");
        
        urlString = [urlString stringByReplacingOccurrencesOfString:@"http://artsearch.nga.gov.au/Images/SML" withString:@"http://artsearch.nga.gov.au/Images/LRG"];
        
        if (providerSpecific[@"troveHoldingNUC"]) {
            NSString* nuc = providerSpecific[@"troveHoldingNUC"];
            if ([nuc isEqualToString:@"WLB"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                urlString = [urlString stringByReplacingOccurrencesOfString:@"png" withString:@"jpg"];
            } else if ([nuc isEqualToString:@"NSL"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                urlString = [urlString stringByReplacingOccurrencesOfString:@"t.jpg" withString:@"h.jpg"];
                urlString = [urlString stringByReplacingOccurrencesOfString:@"_DAMt" withString:@"_DAMx"];
                urlString = [urlString stringByReplacingOccurrencesOfString:@"acms.sl.nsw.gov.au" withString:@"143.119.202.10"];
            } else if ([nuc isEqualToString:@"AAAR:PS"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                NSArray* equalsComponents = [urlString componentsSeparatedByString:@"="];
                NSString* imageId = equalsComponents.lastObject;
                urlString = [NSString stringWithFormat:@"http://recordsearch.naa.gov.au/NAAMedia/ShowImage.asp?B=%@&T=P&S=1",imageId];
            } else if ([nuc isEqualToString:@"ANL"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                urlString = [urlString stringByReplacingOccurrencesOfString:@"-t" withString:@"-v"];
            } else if ([nuc isEqualToString:@"QSCL"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                urlString = [urlString stringByReplacingOccurrencesOfString:@"t.jpg" withString:@".jpg"];
            } else if ([nuc isEqualToString:@"NMUS:E"]) {
                NSLog(@"KNOWN NUC: %@ (Larger available)", nuc);
                // this has a larger image available but its weirdly tiled...would take work to put back together.
                urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbs" withString:@"TLF_mediums"];
            } else if ([nuc isEqualToString:@"VNMU:I"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                urlString = [urlString stringByReplacingOccurrencesOfString:@"_HoverThumb" withString:@"_Large"];
            } else if ([nuc isEqualToString:@"VMUA"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                NSString* lastPathComponent = urlString.lastPathComponent;
                lastPathComponent = [lastPathComponent stringByReplacingOccurrencesOfString:@"t" withString:@""];
                urlString = [[urlString stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@", lastPathComponent];
            } else if ([nuc isEqualToString:@"YUF"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                // this is a flickr image, really I should detect this by parsing the URL and use the Flickr API to get the largest available image url
                urlString = [urlString stringByReplacingOccurrencesOfString:@"_t.jpg" withString:@"_b.jpg"];
            } else if ([nuc isEqualToString:@"AAWM"]) {
                NSLog(@"KNOWN NUC: %@", nuc);
                NSLog(@"THUMBNAIL: %@", urlString);
                NSLog(@"TROVE URL: %@", providerSpecific[@"troveUrl"]);

                urlString = [urlString stringByReplacingOccurrencesOfString:@"http://cas.awm.gov.au/thumb_img/" withString:@"http://www.awm.gov.au/collection/images/screen/"];
                urlString = [urlString stringByAppendingString:@".jpg"];
            } else {
                NSLog(@"UNKNOWN NUC: %@", nuc);
                NSLog(@"THUMBNAIL: %@", urlString);
                NSLog(@"TROVE URL: %@", providerSpecific[@"troveUrl"]);
            }
        }
    } else if ([providerName isEqualToString:@"University of Washington Libraries Digital Collections"]) {
        NSLog(@"KNOWN: %@", providerName);
        urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
    } else if ([providerName isEqualToString:@"University of Nevada, Las Vegas Digital Collections"]) {
        NSLog(@"KNOWN: %@", providerName);
        // TODO: figure out contentDM version 5 - how to get image info?
        urlString = [urlString stringByReplacingOccurrencesOfString:@"thumbnail.exe" withString:@"getimage.exe"];
        urlString = [urlString stringByAppendingString:@"&action=2&DMSCALE=25&DMWIDTH=2048&DMHEIGHT=2048"];
    } else if ([providerName isEqualToString:@"University of Michigan Library Repository"]) {
        NSLog(@"KNOWN: %@", providerName);
        if (providerSpecific[@"troveHoldingValue"]) {
            NSURL* url = [NSURL URLWithString:providerSpecific[@"troveHoldingValue"]];
            NSURLRequest *subrequest = [NSURLRequest requestWithURL:url];
            AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:subrequest];
            [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSArray* components = [webpageHTML componentsSeparatedByString:@";attachment=1\">Largest size"];
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
    } else {
        NSLog(@"UNKNOWN PROVIDER: %@", providerName);
        NSLog(@"THUMBNAIL: %@", urlString);
        NSLog(@"TROVE URL: %@", providerSpecific[@"troveUrl"]);
    }
    
    if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
        if (completion) {
            completion([NSURL URLWithString:urlString],item);
        }
    }
    
}

@end
