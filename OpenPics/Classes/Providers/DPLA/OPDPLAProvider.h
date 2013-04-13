//
//  OPDPLAProvider.h
//  OpenPics
//
//  Created by PJ Gray on 4/13/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPProvider.h"

extern NSString* const OPProviderTypeDPLA;

@interface OPDPLAProvider : OPProvider

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                completion:(void (^)(NSArray* items, BOOL canLoadMore))completion;

@end
