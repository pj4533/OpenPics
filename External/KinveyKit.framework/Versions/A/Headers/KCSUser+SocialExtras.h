//
//  KCSUser+SocialExtras.h
//  KinveyKit
//
//  Copyright (c) 2012-2014 Kinvey. All rights reserved.
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

@class ACAccount;

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

/** Calls the Twitter reverse auth service to obtain an access token for the native user.
 
 In order for this method to succeed, you need to register an application with Twitter ( https://dev.twitter.com ) and supply the app's client key and client secret when setting up KCSClient (as `KCS_TWITTER_CLIENT_KEY`, and `KCS_TWITTER_CLIENT_SECRET`). 
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 If the user has multiple twitter accounts configured in Settings, this will use the first one in the list. If you wish to let the user select from multiple accounts, you will have to write your own helper to obtain the list of accounts and get the auth token. See https://dev.twitter.com/docs/ios/using-reverse-auth and https://developer.apple.com/library/ios/documentation/Accounts/Reference/ACAccountStoreClassRef/ACAccountStore.html .
 
 @param completionBlock the block to be called when the request completes or faults.
 @since 1.9
 */
+ (void) getAccessDictionaryFromTwitterFromPrimaryAccount:(KCSLocalCredentialBlock)completionBlock;

/** Calls the Twitter reverse auth service to obtain an access token for the native user.
 
 In order for this method to succeed, you need to register an application with Twitter ( https://dev.twitter.com ) and supply the app's client key and client secret when setting up KCSClient (as `KCS_TWITTER_CLIENT_KEY`, and `KCS_TWITTER_CLIENT_SECRET`).
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 If the user has multiple twitter accounts configured in Settings, use the `accountChooseBlock` to select which account to use. This can be done simply by choosing the first acocunt, or by presenting the user with a view to select from a list.
 
 @param completionBlock the block to be called when the request completes or faults.
 @param chooseBlock must return a twitter account from the supplied list. CANNOT be `nil`. This block may be called on an arbitrary thread. 
 @since 1.26.1
 */
+ (void) getAccessDictionaryFromTwitterFromTwitterAccounts:(KCSLocalCredentialBlock)completionBlock accountChooseBlock:(ACAccount* (^)(NSArray* twitterAccounts))chooseBlock;


/** Calls LinkedIn to obtain a user's auth token. You have to specify `KCS_LINKEDIN_API_KEY`, `KCS_LINKEDIN_SECRET_KEY`,  `KCS_LINKEDIN_ACCEPT_REDIRECT`, and `KCS_LINKEDIN_CANCEL_REDIRECT` in the `KCSClient` set-up. A web view is needed in order to display LinkedIn's sign-in page. A user must enter LinkedIn credentials and press "Allow access". If the user cancels or the system is unable to verify the app credentials, the process will fail.
 
 This method just access the basic profile information. Use the signature that takes a permission for additional access to the LinkedIn account.
 
 If sucessful, the completion block will provide a dictionary ready for `+[KCSUser loginWithWithSocialIdentity:accessDictionary:withCompletionBlock]`.
 
 It is the caller's responsbility to dismiss the web view, if necessary. If a user mistypes his/her LinkedIn credentials, the page will display an error, and Kinvey will not be called until the operation is successful or cancelled.
 
 You have the ability to specify text and logos for the sign-in form through the LinkedIn developer portal for your application.
 
 @param completionBlock the block to be called when the request completes or faults. This is the place to dismiss the webview if necessary.
 @param webview for showing the LinkedIn access form. 
 @since 1.13
 */
+ (void) getAccessDictionaryFromLinkedIn:(KCSLocalCredentialBlock)completionBlock usingWebView:(KCSWebViewClass*) webview;

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
