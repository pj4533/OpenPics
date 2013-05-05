// OPLIFEProvider.m
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

#import "OPLIFEProvider.h"
#import "OPImageItem.h"
#import "TTTURLRequestFormatter.h"
#import "AFJSONRequestOperation.h"

NSString * const OPProviderTypeLIFE = @"com.saygoodnight.LIFE";

@implementation OPLIFEProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        self.providerName = @"LIFE Magazine";
    }
    return self;
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion {
    
    NSString* startValue = [NSString stringWithFormat:@"%d", (pageNumber.integerValue - 1) * 20];
    NSString* queryUrlString = [NSString stringWithFormat:@"http://images.google.com/search?q=%@ source:life&tbm=isch&sout=1&biw=1899&bih=1077&sa=N&start=%@&tbs=isz:m", queryString,startValue];
    queryUrlString = [queryUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:queryUrlString];
    
    NSLog(@"(LIFE GET) %@", queryUrlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSArray* comp = [webpageHTML componentsSeparatedByString:@"images.google.com/hosted/life/"];
        
        NSMutableDictionary* imageIds = [NSMutableDictionary dictionary];
        NSMutableArray* retArray = [NSMutableArray array];
        for (int i=1; i < comp.count; i++) {
            NSArray* comp2 = [comp[i] componentsSeparatedByString:@".html"];
                        
            NSString* urlString = [NSString stringWithFormat:@"http://www.gstatic.com/hostedimg/%@_landing", comp2[0]];
            NSURL* imageUrl = [NSURL URLWithString:urlString];
            NSString* titleString = @"";
//
//            NSArray* titleComps = [comp2[1] componentsSeparatedByString:@"<cite title=\"images.google.com\">images.google.com</cite><br>"];
//            if (titleComps.count == 2) {
//                NSArray* innerComps = [titleComps[1] componentsSeparatedByString:@"<br>"];
//                titleString = innerComps[0];
//                titleString = [titleString stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
//                titleString = [titleString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
//                titleString = [titleString stringByReplacingOccurrencesOfString:@" - Hosted" withString:@""];
//            }

            NSDictionary* opImageDict = @{
                                          @"imageUrl": imageUrl,
                                          @"title" : titleString,
                                          @"providerSpecific" : @{@"imageId": comp2[0]}
                                          };
            imageIds[comp2[0]] = opImageDict;
        }
        
        for (NSString* thisKey in imageIds.allKeys) {
            NSDictionary* thisImage = imageIds[thisKey];
            OPImageItem* item = [[OPImageItem alloc] initWithDictionary:thisImage];
            [retArray addObject:item];
        }
        
        BOOL returnCanLoadMore = NO;
        NSRange textRange;
        textRange =[webpageHTML rangeOfString:@"\">Next"];
        if(textRange.location != NSNotFound)
            returnCanLoadMore = YES;
        
        if (completion) {
            completion(retArray,returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    [httpOperation start];
}

- (void) upRezItem:(OPImageItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPImageItem* item))completion {
    
    NSString* imageId = item.providerSpecific[@"imageId"];
    
    NSString* urlString = item.imageUrl.absoluteString;
    urlString = [urlString stringByReplacingOccurrencesOfString:@"_landing" withString:@"_large"];
    
    NSString* queryUrlString = [NSString stringWithFormat:@"http://images.google.com/hosted/life/%@.html", imageId];
    NSURL *url = [NSURL URLWithString:queryUrlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation* httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* webpageHTML = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSArray* compArray = [webpageHTML componentsSeparatedByString:@"<table id=\"ltable\"><div>"];
        NSArray* compArray2 = [compArray[1] componentsSeparatedByString:@"</div>"];
        item.title = compArray2[0];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
        
        if (![urlString isEqualToString:item.imageUrl.absoluteString]) {
            if (completion) {
                completion([NSURL URLWithString:urlString], item);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    [httpOperation start];
    
}


@end
