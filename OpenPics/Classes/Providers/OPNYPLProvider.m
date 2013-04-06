//
//  OPNYPLProvider.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPNYPLProvider.h"
#import "AFNYPLAPIClient.h"

@implementation OPNYPLProvider

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items))completion {

    NSDictionary* parameters = @{
                          @"q":queryString,
                          @"per_page" : @"50",
                          @"page":pageNumber
                          };
    
    [[AFNYPLAPIClient sharedClient] getItemsWithParameters:parameters success:^(NSArray *items) {
        if (completion) {
            completion(items);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];

}

@end
