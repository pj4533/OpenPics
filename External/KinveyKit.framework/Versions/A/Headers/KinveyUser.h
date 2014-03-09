//
//  KinveyUser.h
//  KinveyKit
//
//  Copyright (c) 2008-2014, Kinvey, Inc. All rights reserved.
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
#import "KinveyPersistable.h"
#import "KinveyEntity.h"
#import "KinveyHeaderInfo.h"
#import "KCSBlockDefs.h"

@class KCSCollection;
@class KCSMetadata;

// Need to predefine our classes here
@class KCSUser;
@class KCSUserResult;

typedef enum KCSUserActionResult : NSInteger {
    KCSUserNoInformation = -1,
    KCSUserCreated = 1,
    KCSUserDeleted = 2,
    KCSUserFound = 3,
    KCSUSerNotFound = 4
} KCSUserActionResult;

typedef void (^KCSUserCompletionBlock)(KCSUser* user, NSError* errorOrNil, KCSUserActionResult result);
typedef void (^KCSUserSendEmailBlock)(BOOL emailSent, NSError* errorOrNil);
typedef void (^KCSUserCheckUsernameBlock)(NSString* username, BOOL usernameAlreadyTaken, NSError* error);

/** Social Network login providers supported for log-in
 */
typedef enum  {
    /** Facebook */
    KCSSocialIDFacebook,
    /** Twitter */
    KCSSocialIDTwitter,
    /** LinkedIn */
    KCSSocialIDLinkedIn,
    /** Salesforce */
    KCSSocialIDSalesforce,
    KCSSocialIDOther,
} KCSUserSocialIdentifyProvider;

/** Access Dictionary key for the token: both Facebook & Twitter */
KCS_CONSTANT KCSUserAccessTokenKey;
/** Access Dictionary key for the token secret: just Twitter */
KCS_CONSTANT KCSUserAccessTokenSecretKey;

/** Notification type. This is called when a user is logged in or logged out. `userInfo` and `object` are nil. Query `+[KCSUser activeUser] to get the new value. */
KCS_CONSTANT KCSActiveUserChangedNotification;

/*!  Describes required methods for an object wishing to be notified about the status of user actions.
 *
 * This Protocol should be implemented by a client for processing the results of any User Actions against the Kinvey
 * service that deals with users.
 *
 * The completion status is one of the following: 
 * 
 * - KCSUserCreated
 * - KCSUserDeleted
 * - KCSUserFound
 * - KCSUSerNotFound
 * 
 */
@protocol KCSUserActionDelegate <NSObject>

///---------------------------------------------------------------------------------------
/// @name Success
///---------------------------------------------------------------------------------------
/*! Called when a User Request completes successfully.
 * @param user The user the action was performed on.
 * @param result The results of the completed request
 *
 */
- (void)user: (KCSUser *)user actionDidCompleteWithResult: (KCSUserActionResult)result;

///---------------------------------------------------------------------------------------
/// @name Failure
///---------------------------------------------------------------------------------------
/*! Called when a User Request fails for some reason (including network failure, internal server failure, request issues...)
 * 
 * Use this method to handle failures.
 *  @param user The user the operation was performed on.
 *  @param error An object that encodes our error message.
 */
- (void)user: (KCSUser *)user actionDidFailWithError: (NSError *)error;

@end

/** Constant for use in querying the username field */
KCS_CONSTANT KCSUserAttributeUsername;
/** Constant for use in querying the surname field */
KCS_CONSTANT KCSUserAttributeSurname;
/** Constant for use in querying the given name field */
KCS_CONSTANT KCSUserAttributeGivenname;
/** Constant for use in querying the email field */
KCS_CONSTANT KCSUserAttributeEmail;
/** Constant for querying by Facebook id 
 @since 1.10.5
 */
KCS_CONSTANT KCSUserAttributeFacebookId;

/*! User in the Kinvey System
 
 All Kinvey requests must be made using an authorized user, if a user doesn't exist, an automatic user generation
 facility exists (given a username Kinvey can generate and store a password).  More user operations are available to the
 client, but are not required to be used.
 
 Since all requests *must* be made through a user, the library maintains the concept of a current user, which is the
 user used to make all requests.  Convienience routines are available to manage the state of this Current User.
 
 Like other entities, KCSUsers can have different levels of access control. The `user` collection can be made private in the Kinvey console; if it is private, users will still have four fields that can be queried publicly: username, surname, given name, and email. These can be discovered with `KCSUserDiscovery`.
 
 Like other entities, the `metadata` property can be modified to control access on a user-by-user basis, beyond the `user` collection-wide settings. 
 
 @see KCSMetadata
 @see KCSPersistable
 */
@interface KCSUser : NSObject <KCSPersistable>

///---------------------------------------------------------------------------------------
/// @name User Information
///---------------------------------------------------------------------------------------

/*! Username of this Kinvey User. Publicly queryable be default. */
@property (nonatomic, copy) NSString *username;

/*! Password of this Kinvey User
 @deprecatedIn 1.25.0 
 @deprecated password is no longer stored
 */
@property (nonatomic, copy) NSString *password KCS_DEPRECATED(Password no longer stored in library, 1.25.0);

/** The Kinvey user collection id for the user */
@property (nonatomic, strong) NSString *userId;

/*! Device Tokens of this User */
@property (nonatomic, readonly, strong) NSMutableSet *deviceTokens;

/*! Session Auth Token, if available
 @deprecated token now lives in the keychain
 @deprecatedIn 1.25.0
 */
@property (nonatomic, copy) NSString *sessionAuth  KCS_DEPRECATED(Token no longer stored with the user object, 1.25.0);;

/*! Access Control Metadata of this User
 @see KCSPersistable
 */
@property (nonatomic, strong) KCSMetadata *metadata;

/** Optional surname for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *surname;

/** Optional given (first) name for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *givenName;

/** Optional email address for the user. Publicly queryable be default. */
@property (nonatomic, copy) NSString *email;

/** Checks if the user has verified email (by clicking the link in the email sent via `sendEmailConfirmationForUser:withCompletionBlock:`).
 @see sendEmailConfirmationForUser:withCompletionBlock:
 @since 10.1.0
 */
@property (nonatomic) BOOL emailVerified;

/** Checks if credentials have been stored in the keychain. 
 
 This is useful to check if a user will be loaded on the first call to Kinvey, or if an implicit user will be created instead. 
 */
+ (BOOL) hasSavedCredentials;

/** Clears and saved credentials from the keychain.
 */
+ (void) clearSavedCredentials;

/** The currently active user of the application.
 
 If there are saved credentials and the user has not be initialized yet, this will initialize it from the keychain.
 
 @return the user object for the current user. `nil` if the user has not been set yet or has been cleared.
 @since 1.11.0
 */
+ (KCSUser *)activeUser;

///---------------------------------------------------------------------------------------
/// @name KinveyKit Internal Services
///---------------------------------------------------------------------------------------
/*! Initialize the "Current User" for Kinvey
 
 This will cause the system to initialize the "Current User" to the known "primary" user for the device
 should no user exist, one is created.
 
 @warning This routine is not intended for application developer use, this routine is used by the library runtime to ensure all requests are authenticated.
 
 @warning This is a *blocking* routine and will block on other threads that are authenticating.  There is a short timeout before authentication failure.
 @deprecatedIn 1.19.0
 */
- (void)initializeCurrentUser KCS_DEPRECATED(do not call this directly, 1.19.0);

///---------------------------------------------------------------------------------------
/// @name Creating Users
///---------------------------------------------------------------------------------------

/*! Create a new Kinvey user and register them with the backend.
 * @param username The username to create, if it already exists on the back-end an error will be returned.
 * @param password The user's password
 * @param delegate The delegate to inform once creation completes
 * @deprecatedIn 1.19.0
*/
+ (void)userWithUsername: (NSString *)username password: (NSString *)password withDelegate: (id<KCSUserActionDelegate>)delegate KCS_DEPRECATED(use userWithUsername:password:withCompletionBlock: instead, 1.19.0);


/** Create a new Kinvey user and register them with the backend.
 * @param username The username to create, if it already exists on the back-end an error will be returned.
 * @param password The user's password
 * @param completionBlock The callback to perform when the creation completes (or errors).
 @deprecated Use +[KCSUser userWithUsername:password:fieldsAndValues:withCompletionBlock:] instead with `nil`.
 @deprecatedIn 1.25.0
 */
+ (void) userWithUsername:(NSString *)username password:(NSString *)password withCompletionBlock:(KCSUserCompletionBlock)completionBlock KCS_DEPRECATED(Use +[KCSUser userWithUsername:password:fieldsAndValues:withCompletionBlock:] instead, 1.25.0);

/** Create a new Kinvey user and register them with the backend.
 * @param username The username to create, if it already exists on the back-end an error will be returned.
 * @param password The user's password
 * @param completionBlock The callback to perform when the creation completes (or errors).
 @param fieldsAndValues additional data to populate the user object, such as `KCSUserAttributeSurname`, `KCSUserAttributeGivenname` and `KCSUserAttributeEmail`. Can be `nil`.
 @since 1.25.0
 */
+ (void) userWithUsername:(NSString *)username password:(NSString *)password fieldsAndValues:(NSDictionary*)fieldsAndValues withCompletionBlock:(KCSUserCompletionBlock)completionBlock;

/** Creates a unique user with a default username and password.
 
 When complete, this method will register the new user as the `activeUser`.
 
 @param completionBlock The callback to perform when the creation completes (or errors).
 @since 1.19.0
 @deprecated Use +[KCSUser createAutogeneratedUser:completion:] instead with `nil`.
 @deprecatedIn 1.25.0
 */
+ (void) createAutogeneratedUser:(KCSUserCompletionBlock)completionBlock KCS_DEPRECATED(Use +[KCSUser createAutogeneratedUser:completion:] instead, 1.25.0);

/** Creates a unique user with a default username and password.
 
 When complete, this method will register the new user as the `activeUser`.
 
 @param completionBlock The callback to perform when the creation completes (or errors).
 @param fieldsAndValues additional data to populate the user object, such as `KCSUserAttributeSurname`, `KCSUserAttributeGivenname` and `KCSUserAttributeEmail`. Can be `nil`.
 @since 1.25.0
 */
+ (void) createAutogeneratedUser:(NSDictionary *)fieldsAndValues completion:(KCSUserCompletionBlock)completionBlock;


///---------------------------------------------------------------------------------------
/// @name Managing the Current User
///---------------------------------------------------------------------------------------

/** Loads the user data from the keychain and sets as the `activeUser`.
 @since 1.19.0
 */
+ (KCSUser*)initAndActivateWithSavedCredentials;

/*! Login an existing user, generates an error if the user doesn't exist
 * @param username The username of the user
 * @param password The user's password
 * @param delegate The delegate to inform once the action is complete
 * @deprecatedIn 1.19.0
*/
+ (void)loginWithUsername: (NSString *)username password: (NSString *)password withDelegate: (id<KCSUserActionDelegate>)delegate KCS_DEPRECATED([Use loginWithUsername:password:withCompletionBlock: instead, 1.19.0);

/*! Login an existing user, generates an error if the user doesn't exist
 * @param username The username of the user
 * @param password The user's password
 * @param completionBlock The block that is called when the action is complete
 */
+ (void)loginWithUsername: (NSString *)username
                 password: (NSString *)password 
      withCompletionBlock:(KCSUserCompletionBlock)completionBlock;

/** Login a user with social network access information.
 
 This creates a new Kinvey user or logs in with an existing one associated with the supplied access token. Kinvey will verify the token with the social provider on the server and return an authorized Kinvey user if the process is sucessful.
 
 __Facebook:__
 
 To obtain the access token, download the Facebook SDK (https://developers.facebook.com/ios/) and follow the instructions for session log-in. Once the token is obtained, provide it in a dictionary: `[KCSUser loginWithSocialIdentity:KCSSocialIDFacebook accessDictionary:{ KCSUserAccessTokenKey : <#FB Access Token#>} withCompletionBlock:<# completion block #>]`. 
 
 __ Twitter: __
 
 To obtain the access token, follow Twitter's instructions to independently obtain the token ( https://dev.twitter.com/docs/auth/obtaining-access-tokens ) or if you want to use the native Twitter account in iOS 5 & 6 use `+ [KCSUser getAccessDictionaryFromTwitterFromPrimaryAccount:]`. This requires use of Twitter.framewwork and Accounts.framework, and to have your app provisioned for reverse auth.  
 
     [KCSUser getAccessDictionaryFromTwitterFromPrimaryAccount:^(NSDictionary *accessDictOrNil, NSError *errorOrNil) {
        [KCSUser loginWithSocialIdentity:KCSSocialIDTwitter accessDictionary:accessDictOrNil withCompletionBlock:<# completion block #>]
      }];
 
 When using your own method for obtaining the token, Twitter requires that you provide the `oauth_token` and `oauth_token_secret` to log-in. `[KCSUser loginWithSocialIdentity:KCSSocialIDTwitter accessDictionary:{ KCSUserAccessTokenKey : <# Twitter OAuth Token #>, KCSUserAccessTokenSecretKey : <# Twitter OAuth Token Secret #>} withCompletionBlock:<# completion block #>]`.
 
 Regardless of the the token is obtained, your Twitter app credentials must also be supplied when creating the KCSClient. Specify the `KCS_TWITTER_CLIENT_KEY` and `KCS_TWITTER_CLIENT_SECRET` in the options dictionary when the app is launched. These credentials are used for reverse auth and on the server side to verify the token with Twitter. 
 
 @param provider the enumerated social network identity provider
 @param accessDictionary the credentials needed to authenticate the user for log-in
 @param completionBlock the block to be called when the operation completes or fails
 @since 1.9.0
 */
+ (void)loginWithSocialIdentity:(KCSUserSocialIdentifyProvider)provider accessDictionary:(NSDictionary*)accessDictionary withCompletionBlock:(KCSUserCompletionBlock)completionBlock;

/*! Removes a user and their data from Kinvey
 * @param completionBlock The block that is called when operation is complete or fails.
 */
- (void) removeWithCompletionBlock:(KCSCompletionBlock)completionBlock;

/*! Logout the user.
*/
- (void)logout;

///---------------------------------------------------------------------------------------
/// @name Updating the user object
///---------------------------------------------------------------------------------------
                                                                                                                                                 
/** Update the user object from the server.
 
 The block will return and automatically update the `activeUser`.
 
 __NOTE:__ this only works for the active user. Otherwise there will be an error.
 
 @param completionBlock called when the refresh is complete or fails. The `objectsOrNil` property will have only the user, if there is no error.
 @since 1.19.0
 */
- (void) refreshFromServer:(KCSCompletionBlock)completionBlock;
                                                                                                                                                 
/** Called to update the Kinvey state of a user.
  @param completionBlock block called upon completion or error
  @since 1.11.0
 */
- (void) saveWithCompletionBlock:(KCSCompletionBlock)completionBlock;

//---------------------------------------------------------------------------------------
/// @name Using User Attributes
///---------------------------------------------------------------------------------------
                                                                                                                                                 
/*! Return the value for an attribute for this user
 * @param attribute The attribute to retrieve
 */
- (id)getValueForAttribute: (NSString *)attribute;

/*! Set the value for an attribute
 * @param value The value to set.
 * @param attribute The attribute to modify.
 */
- (void)setValue: (id)value forAttribute: (NSString *)attribute;

/** Remove a stored attribute. No error if the attribute has not been set.
 * @param attribute The attribute to modify.
 */

- (void) removeValueForAttribute:(NSString*)attribute;

/** Update a user's password and save the user object to the backend. 
 @param newPassword the new password for the user
 @param completionBlock block to be notified when operation is completed or fails. The `objectsOrNil` return array will have the updated user as its only value if successful. 
 @sicne 1.13.0
 */
- (void) changePassword:(NSString*)newPassword completionBlock:(KCSCompletionBlock)completionBlock;

///---------------------------------------------------------------------------------------
/// @name User email management
///---------------------------------------------------------------------------------------

/** Sends a password reset email to the specified user.
 
 The user must have a valid email set in its email (`KCSUserAttributeEmail`) field, on the server, for this to work. The user will receive an email with a time-bound link to a password reset web page.
 
 Until the password reset is complete, the old password remains active and valid. This allows the user to ignore the request if he remembers the old password. If too much time has passed, the email link will no longer be valid, and the user will have to initiate a new sendPasswordResetForUser:withCompletionBlock:.
 
 If the user knows his current password and is logged in, but wants to change the password, it can just be done with the - [KCSUser setPassword:] method followed by saving the current user to the back-end.
 
 @param usernameOrEmail the username or user email to send the password reset link to
 @param completionBlock the request callback. `emailSent` is true if the email address is found and an email is sent (does not guarantee delivery). If `emailSent` is `NO`, then the `errorOrNil` value will have information as to what went wrong on the network. For security reasons, `emailSent` will be true even if the user is not found or the user does not have an associated email.
 @since 1.10.0
 */
+ (void) sendPasswordResetForUser:(NSString*)usernameOrEmail withCompletionBlock:(KCSUserSendEmailBlock)completionBlock;

/** Sends a username reminder email to the specified user.
 
 @param email the email address to send a reminder to
 @param completionBlock returns `true` if the system received the request, regardless if the email is valid, associated with a user, or actually sent. The error object will be non-nil if a network error occurred.
 @since 1.19.0
 */
+ (void) sendForgotUsername:(NSString*)email withCompletionBlock:(KCSUserSendEmailBlock)completionBlock;

/** Sends an request to confirm email address to the specified user.
 
 The user must have a valid email set in its email (`KCSUserAttributeEmail`) field, on the server, for this to work. The user will receive an email with a time-bound link to a verification web page.
 
 @param username the user to send the password reset link to
 @param completionBlock the request callback. `emailSent` is true if the email address is found and an email is sent (does not guarantee delivery). If `emailSent` is `NO`, then the `errorOrNil` value will have information as to what went wrong on the network. For security reasons, `emailSent` will be true even if the user is not found or the user does not have an associated email.
 @since 1.10.1
 */
+ (void) sendEmailConfirmationForUser:(NSString*)username withCompletionBlock:(KCSUserSendEmailBlock)completionBlock;

/** Checkes the server to see if a username is already being used.
 
 This method is useful to pre-check a username before a new user is created. 
 
 See http://devcenter.kinvey.com/rest/guides/users#userexists for more information
 
 @param potentialUsername the username to check
 @param completionBlock if there is no error, `usernameAlreadyTaken` will be `YES` if that username is in use, and `NO` if it is available
 @since 1.16.0
*/
+ (void) checkUsername:(NSString*)potentialUsername withCompletionBlock:(KCSUserCheckUsernameBlock)completionBlock;


@end
