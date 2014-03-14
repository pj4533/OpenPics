//
//  AFLOCSessionManager.h
//
//  Created by PJ Gray on 8/12/12.
//  Copyright (c) 2012 PJ Gray. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFLOCSessionManager : AFHTTPSessionManager

+ (AFLOCSessionManager*) sharedClient;

@end
