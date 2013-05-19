//
//  KCSUser+SocialExtras.h
//  KinveyKit
//
//  Created by Michael Katz on 9/18/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "KinveyKit.h"
#import "KCSWebView.h"

/** Completion block for `getAccessDictionaryFromTwitterFromPrimaryAccount:` returns either the access dictionary to pass to `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]` or an error.
 */
typedef void (^KCSLocalCredentialBlock)(NSDictionary* accessDictOrNil, NSError* errorOrNil);

/**
 These are additional helpers for KCSUser to obtain credentials from social services. This requires linking in `Twitter.framework` and `Accounts.framework`.
 @since 1.9
 */
@interface KCSUser (SocialExtras)

/**
 Checks that the a twitter account has been set up by the user on the device and that the KCSClient has been configured to obtain an auth token.
 @return true if there is enough information to request an access token from twitter
 @since 1.9
 */
+ (BOOL) canUseNativeTwitter;

/** Calls the Twitter reverse auth service to obtain an access token for the native user.
 
 In order for this method to succeed, you need to register an application with Twitter ( https://dev.twitter.com ) and supply the app's client key and client secret when setting up KCSClient (as `KCS_TWITTER_CLIENT_KEY`, and `KCS_TWITTER_CLIENT_SECRET`). 
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 If the user has multiple twitter accounts configured in Settings, this will use the first one in the list. 
 
 @param completionBlock the block to be called when the request completes or faults.
 @since 1.9
 */
+ (void) getAccessDictionaryFromTwitterFromPrimaryAccount:(KCSLocalCredentialBlock)completionBlock;

/** Calls LinkedIn to obtain a user's auth token. You have to specify `KCS_LINKEDIN_API_KEY`, `KCS_LINKEDIN_SECRET_KEY`,  `KCS_LINKEDIN_ACCEPT_REDIRECT`, and `KCS_LINKEDIN_CANCEL_REDIRECT` in the `KCSClient` set-up. A web view is needed in order to display LinkedIn's sign-in page. A user must enter LinkedIn credentials and press "Allow access". If the user cancels or the system is unable to verify the app credentials, the process will fail.
 
 This method just access the basic profile information. Use the signature that takes a permission for additional access to the LinkedIn account.
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 It is the caller's responsbility to dismiss the web view, if necessary. If a user mistypes his/her LinkedIn credentials, the page will display an error, and Kinvey will not be called until the operation is successful or cancelled.
 
 You have the ability to specify text and logos for the sign-in form through the LinkedIn developer portal for your application.
 
 @param completionBlock the block to be called when the request completes or faults. This is the place to dismiss the webview if necessary.
 @param webview for showing the LinkedIn access form. 
 @since 1.13
 */
#if TARGET_OS_IPHONE
+ (void) getAccessDictionaryFromLinkedIn:(KCSLocalCredentialBlock)completionBlock usingWebView:(KCSWebViewClass*) webview;
#else
+ (void) getAccessDictionaryFromLinkedIn:(KCSLocalCredentialBlock)completionBlock usingWebView:(KCSWebViewClass*) webview;
#endif

/** Calls LinkedIn to obtain a user's auth token. You have to specify `KCS_LINKEDIN_API_KEY`, `KCS_LINKEDIN_SECRET_KEY`,  `KCS_LINKEDIN_ACCEPT_REDIRECT`, and `KCS_LINKEDIN_CANCEL_REDIRECT` in the `KCSClient` set-up. A web view is needed in order to display LinkedIn's sign-in page. A user must enter LinkedIn credentials and press "Allow access". If the user cancels or the system is unable to verify the app credentials, the process will fail.
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 It is the caller's responsbility to dismiss the web view, if necessary. If a user mistypes his/her LinkedIn credentials, the page will display an error, and Kinvey will not be called until the operation is successful or cancelled.
 
 You have the ability to specify text and logos for the sign-in form through the LinkedIn developer portal for your application.
 
 @param completionBlock the block to be called when the request completes or faults. This is the place to dismiss the webview if necessary.
 @param permissions the level of access to the user's account. For example, `@"r_network"` will retreive the user's profile as well as his connections. Since the LinkedIn documentation for the full list of values.
 @param webview for showing the LinkedIn access form.
 @since 1.15.1
 */
+ (void) getAccessDictionaryFromLinkedIn:(KCSLocalCredentialBlock)completionBlock permissions:(NSString*)permissions usingWebView:(KCSWebViewClass*) webview;

@end
