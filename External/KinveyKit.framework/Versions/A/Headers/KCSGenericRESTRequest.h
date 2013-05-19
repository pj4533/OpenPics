//
//  KCSGenericRESTRequest.h
//  KinveyKit
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.


#import <Foundation/Foundation.h>
#import "KinveyBlocks.h"

typedef enum {
    kGetRESTMethod     = 0,
    kPutRESTMethod     = 1,
    kPostRESTMethod    = 2,
    kDeleteRESTMethod  = 3
} KCSRESTMethod;

#define KCS_JSON_TYPE @"application/json; charset=utf-8"
#define KCS_DATA_TYPE @"application/octet-stream"

@interface KCSGenericRESTRequest : NSObject

@property (nonatomic, copy) NSString *resourceLocation;
@property (nonatomic, copy) NSMutableDictionary *headers;
@property (nonatomic) NSInteger method;
@property (nonatomic) BOOL followRedirects;

- (id)initWithResource:(NSString *)resource usingMethod: (NSInteger)requestMethod;

+ (KCSGenericRESTRequest *)requestForResource: (NSString *)resource usingMethod: (NSInteger)requestMethod withCompletionAction: (KCSConnectionCompletionBlock)complete failureAction:(KCSConnectionFailureBlock)failure progressAction: (KCSConnectionProgressBlock)progress;
+ (NSString *)getHTTPMethodForConstant:(NSInteger)constant;


- (void)start;
@end
