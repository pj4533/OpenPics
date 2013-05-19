//
//  KCSWebView.h
//  KinveyKit
//
//  Created by Michael Katz on 2/7/13.
//  Copyright (c) 2013 Kinvey. All rights reserved.
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
