//
//  KCSConnectionResponse.h
//  KinveyKit
//
//  Copyright (c) 2008-2012, Kinvey, Inc. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>

@interface KCSConnectionResponse : NSObject

@property (readonly) NSInteger responseCode; // See KinveyHTTPSStatusCodes for definitions
@property (retain, readonly) NSData *responseData;
@property (retain, readonly) NSDictionary *userData;
@property (retain, readonly) NSDictionary *responseHeaders;
@property (retain, readonly) NSString* requestId;


+ (KCSConnectionResponse *)connectionResponseWithCode:(NSInteger)code responseData:(NSData *)data headerData:(NSDictionary *)header userData:(NSDictionary *)userDefinedData; 

- (NSString*) stringValue;
- (id) jsonResponseValue;
- (id) jsonResponseValue:(NSError**) anError;


@end
