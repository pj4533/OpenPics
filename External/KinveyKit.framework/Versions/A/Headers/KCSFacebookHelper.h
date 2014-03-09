//
//  KCSFacebookHelper.h
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

/** Key for the action type
 
 @see +[KCSFacebookHelper parseDeepLink:]
 @since 1.14.2
 */
#define KCSFacebookOGAction @"action"
/** Key for the object type
 
 @see +[KCSFacebookHelper parseDeepLink:]
 @since 1.14.2
 */
#define KCSFacebookOGObjectType @"object"
/** Key for the action type
 
 @see +[KCSFacebookHelper parseDeepLink:]
 @since 1.14.2
 */
#define KCSFacebookOGEntityId @"entityId"

/** Completion block for publishing to open graph
 @param actionId the id for the published story
 @param errorOrNil the error object, if one was generated
 @since 1.14.2
 */
typedef void (^FacebookOGCompletionBlock)(NSString* actionId, NSError* errorOrNil);

/** Helper class for Kinvey/Facebook Integrations.
 
 Supports publishing Open Graph stories and deep linking.
 @since 1.14.2
 */
@interface KCSFacebookHelper : NSObject

///---------------------------------------------------------------------------------------
/// @name Open Graph
///---------------------------------------------------------------------------------------


/** Parses a link to extract the action type, object type, and entity id. These values can be used for loading the appropriate item from the data store. 
 
 If you've supplied the appropriate fb##### url in the info.plist, when a user taps a published open graph story in the Facebook app, it will open your app with a callback url. Implement `application:openURL:sourceApplication:annotation:` in your app delegate class, and pass the supplied url to this method.
 
 E.g.
     
     - (BOOL)application:(UIApplication *)application
                 openURL:(NSURL *)url
       sourceApplication:(NSString *)sourceApplication
              annotation:(id)annotation {
         NSDictionary* items = [KCSFacebookHelper parseDeepLink:url];
         if (items != nil) {
             NSString* entityId = items[KCSFacebookOGEntityId];
             if (entityId != nil) {
                 [self.displayControler displayItem:entityId];
             }
         }
         // ...
 
 
 For an example see: http://devcenter.kinvey.com/rest/tutorials/facebook-opengraph-tutorial
 
 @param url the callback URL. 
 @return a dictionary with the following values: 
 
  * `KCSFacebookOGAction` - the story's action type
  * `KCSFacebookOGObjectType` - the story's object type
  * `KCSFacebookOGEntityId` - the id of the entity in the data store
 
 @since 1.14.2
 */
+ (NSDictionary*) parseDeepLink:(NSURL*)url;

/** Publish an open graph story to the user's timeline.
 
 This method takes an entity in the data store collection mapped to a particular object type and submits that using the specified action.
 
 @param entityId the `KCSEntityKeyId` of the object in the mapped collection
 @param action the actionType. This must be one of the ones specified in the Open Graph data link in the Kinvey console
 @param objectType the object type of the entity. A collection can be mapped to multiple object types
 @param extraParams optional action parameters. E.g. `tags` (friends), `place`, `start_time`, `end_time`, etc.
 @param completionBlock the callback for publishing to Open Graph. `actionId` is the id for the published story; this can be used to read, update, or delete the story separately using the Facebook SDK or API. `errorOrNil` will the error object if one was generated.
 @since 1.14.2
 */
+ (void) publishToOpenGraph:(NSString*)entityId action:(NSString*)action objectType:(NSString*)objectType optionalParams:(NSDictionary*)extraParams completion:(FacebookOGCompletionBlock)completionBlock;

@end
