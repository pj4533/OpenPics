//
//  AFLOCSessionManager.m
//  LOCPix
//
//  Created by PJ Gray on 8/12/12.
//  Copyright (c) 2012 PJ Gray. All rights reserved.
//

#import "AFLOCSessionManager.h"

static NSString * const kAFLOCAPIBaseURLString = @"http://www.loc.gov/pictures/";

@implementation AFLOCSessionManager

+ (AFLOCSessionManager *)sharedClient {
    static AFLOCSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AFLOCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAFLOCAPIBaseURLString]];
        
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    AFJSONResponseSerializer* responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [self setResponseSerializer:responseSerializer];

    return self;
}

@end
