//
//  KCSWebView.h
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

#ifndef KinveyKit_KCSWebView_h
#define KinveyKit_KCSWebView_h

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define KCSWebViewClass UIWebView
#define KCSWebViewDelegate UIWebViewDelegate

#else

#define KCSWebViewClass WebView
#import <WebKit/WebKit.h>
#define KCSWebViewDelegate NSObject

@interface WebView (KCSWebView)
@property (nonatomic, assign) id delegate;
- (void) loadRequest:(NSURLRequest*)request;
@end

#define UIWebViewNavigationType NSInteger

#endif


#endif
