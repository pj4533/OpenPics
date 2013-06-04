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
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
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
            NSString* imageId = comp2[0];
            
            NSArray* comp3 = [comp[i] componentsSeparatedByString:@"&amp;w="];
            NSArray* comp4 = [comp3[1] componentsSeparatedByString:@"&"];

            NSString* width = comp4[0];

            NSArray* comp5 = [comp[i] componentsSeparatedByString:@"&amp;h="];
            NSArray* comp6 = [comp5[1] componentsSeparatedByString:@"&"];

            NSString* height = comp6[0];
            
            NSString* urlString = [NSString stringWithFormat:@"http://www.gstatic.com/hostedimg/%@_landing", imageId];
            NSURL* imageUrl = [NSURL URLWithString:urlString];
            NSString* titleString = @"";

            NSDictionary* opImageDict = @{
                                          @"imageUrl": imageUrl,
                                          @"title" : titleString,
                                          @"providerType": self.providerType,
                                          @"providerSpecific" : @{@"imageId": imageId},
                                          @"width": width,
                                          @"height": height
                                          };
            
            NSLog(@"%@", opImageDict);
            
            imageIds[imageId] = opImageDict;
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
        
        if (success) {
            success(retArray,returnCanLoadMore);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
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
        NSArray* compArray2 = [compArray[1] componentsSeparatedByString:@"<tr><th>"];
        item.title = compArray2[0];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"</strong>" withString:@" "];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"<div>" withString:@""];
        item.title = [item.title stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
        
        NSRange textRange;
        textRange =[compArray[1] rangeOfString:@"Date taken:</th><td>"];
        if(textRange.location != NSNotFound) {
            NSArray* dateComps = [compArray[1] componentsSeparatedByString:@"Date taken:</th><td>"];
            NSArray* dateComps2 = [dateComps[1] componentsSeparatedByString:@"</td>"];
            item.title = [item.title stringByAppendingFormat:@" (%@)", dateComps2[0]];
        }

        
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
