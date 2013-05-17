//
//  KCSAuthCredential.h
//  KinveyKit
//
//  Created by Brian Wilson on 1/17/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCSAuthCredential : NSObject

@property (nonatomic, retain) NSString *URL;
@property (nonatomic) NSInteger method;

- (id)initWithURL: (NSString *)URL withMethod: (NSInteger)method;
+ (KCSAuthCredential *)credentialForURL: (NSString *)URL usingMethod: (NSInteger)method;
- (NSURLCredential *)NSURLCredential;
- (NSString *)HTTPBasicAuthString;
- (BOOL)requiresAuthentication;

@end
