//
//  KCSLogSink.h
//  KinveyKit
//
//  Copyright (c) 2013 Kinvey. All rights reserved.
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
/**
 This protocol is to install a custom logger into KinveyKit's debugging logging system. Use this with KCSClient option `KCS_LOG_SINK` to install the implementing class.
 @since 1.14.0
 */
@protocol KCSLogSink <NSObject>

/** Take the incoming `message` and send it somewhere; e.g. STDOUT, NSLog, or a custom logger.
 
 @see +[KinveyKit configureLoggingWithNetworkEnabled:debugEnabled:traceEnabled:warningEnabled:errorEnabled:]
 @param message the KinveyKit log message
 @since 1.14.0
 */
- (void) log:(NSString*)message;
@end
