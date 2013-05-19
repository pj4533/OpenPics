//
//  NSURL+KinveyAdditions.h
//  SampleApp
//
//  Copyright (c) 2008-2011, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>

/*! Category to add some basic URL Query Support to NSURLs

    This category adds the ability to add queries to an existing NSURL.

    @note A query string to be added will be added using either a '?' or a '+' as appropriate.  Queries should omit the
    leading value.  For example:
    @code
        [[NSURL urlWithString: @"http://kinvey.com/status"] URLByAppendingQueryString: @"value=\"UP\""]
    @endcode
    will result in the NSURL representing http://kinvey.com/status?value="UP"

 */
@interface NSURL (KinveyAdditions)

/*! Generate a NSURL by appending a query to an existing NSURL
    @param queryString The URL Query to append to the current string.
    @returns The URL object made from the URL/query.

 */
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;

/*! Generate a NSURL by percent-encoding an unencoded string.
 @param string an *unencoded* string that needs percent encoding.
 @returns The URL object by percent encoding the string.
 
 */
+ (NSURL *)URLWithUnencodedString:(NSString *)string;

@end
