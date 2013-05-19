//
//  KCSLogSink.h
//  KinveyKit
//
//  Created by Michael Katz on 3/13/13.
//  Copyright (c) 2013 Kinvey. All rights reserved.
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
