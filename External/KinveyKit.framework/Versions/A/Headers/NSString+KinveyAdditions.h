//
//  NSString+KinveyAdditions.h
//  SampleApp
//
//  Copyright (c) 2008-2013, Kinvey, Inc. All rights reserved.
//
// This software is licensed to you under the Kinvey terms of service located at
// http://www.kinvey.com/terms-of-use. By downloading, accessing and/or using this
// software, you hereby accept such terms of service  (and any agreement referenced
// therein) and agree that you have read, understand and agree to be bound by such
// terms of service and are of legal age to agree to such terms with Kinvey.
//
// This software contains valuable confidential and proprietary information of
// KINVEY, INC and is subject to applicable licensing agreements.
// Unauthorized reproduction, transmission or distribution of this file and its
// contents is a violation of applicable laws.
//

#import <Foundation/Foundation.h>

/* Category to add some basic URL Query Support to NSStrings

 This category adds the ability to turn a string into a URL with query parameters, as well as the ability to
 add queries to an existing string representation of a URL.

 @warning A query string to be added will be added using either a '?' or a '&' as appropriate.  Queries should omit the
 leading value.  For example:
    [@"http://kinvey.com/status" URLStringByAppendingQueryString: @"value=\"UP\""]
 will result in the string:
    http://kinvey.com/status?value="UP"
 
 Additionally, this category fixes % encoding strings.

 */
@interface NSString (KinveyAdditions)

/* Generate a NSURL by appending a query to an existing String
 
    Do not add your own '?' or '&' to the front of the query unless you
    need to have that value in the query string.  Otherwise you
    may end up with unexpected characters.
 
    @param queryString The URL Query to append to the current string.
    @return The URL object made from the string/query.

 */
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;

/* Generate a string by appending a query string.
    @param queryString The string to append as a query
    @return The newly created string.
 */
- (NSString *)stringByAppendingQueryString:(NSString *)queryString;

/* Generate a string by appending a properly percent encoded string.
 @param string The string (typically a URL) that needs to be percent encoded.
 @return The newly created string.
 */
- (NSString *)stringByAppendingStringWithPercentEncoding:(NSString *)string;

/* Generate a string by appending a properly percent encoded string.
 @param string The string (typically a URL) that needs to be percent encoded.
 @return The newly created string.
 */
+ (NSString *)stringByPercentEncodingString:(NSString *)string;

/* Tests that the substring is somewhere inside the string
 @param substring the string to look for inside this one.
 */
- (BOOL) containsStringCaseInsensitive:(NSString*)substring;

/* Creates a a UUID string (using CFUUIDCreate)
 */
+ (instancetype) UUID;

@end
