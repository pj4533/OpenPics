// OPBackendKinvey.m
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

#import "OPBackendKinvey.h"
#import "OPBackendTokens.h"
#import <KinveyKit/KinveyKit.h>

@interface OPBackendKinvey () {
    KCSClient* _kinveyClient;
}

@end

@implementation OPBackendKinvey

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
#ifndef kOPBACKEND_KINVEY_APP_KEY
    _backendConfigured = NO;
#else
    _kinveyClient = [[KCSClient sharedClient] initializeKinveyServiceForAppKey:kOPBACKEND_KINVEY_APP_KEY
                                                                 withAppSecret:kOPBACKEND_KINVEY_APP_SECRET
                                                                  usingOptions:nil];
    
    [KCSPing pingKinveyWithBlock:^(KCSPingResult *result) {
        if (result.pingWasSuccessful == YES){
            NSLog(@"Kinvey Ping Success");
        } else {
            NSLog(@"Kinvey Ping Failed");
        }
    }];
    
    _backendConfigured = YES;
#endif
    return self;
}

@end
