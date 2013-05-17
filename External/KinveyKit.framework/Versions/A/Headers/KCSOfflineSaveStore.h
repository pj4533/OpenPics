//
//  KCSOfflineSaveStore.h
//  KinveyKit
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//
//  This software contains valuable confidential and proprietary information of
//  KINVEY, INC and is subject to applicable licensing agreements.
//  Unauthorized reproduction, transmission or distribution of this file and its
//  contents is a violation of applicable laws.

#import <Foundation/Foundation.h>
#import "KCSStore.h"

@protocol KCSPersistable;

/** This is a unique key per store. It is used to map delegates the save queues */
#define KCSStoreKeyUniqueOfflineSaveIdentifier @"KCSStore.OfflineSave.Identifier"
/** This key is for the per-store save delegate.
 @see KCSofflineSaveDelegate
 */
#define KCSStoreKeyOfflineSaveDelegate @"KCSStore.OfflineSave.Delegate"

/** If an error is returned from [KCSStore saveObject:withCompletionBlock:withProgressBlock], the error's `userInfo` will contain an array of the ids for the objects not saved. `NSNull`s will be used for objects that have not had their ids set yet. */
#define KCS_ERROR_UNSAVED_OBJECT_IDS_KEY @"KCSStore.OfflineSave.UnsavedObjectIds"

/** If a `KCSStore` implements this additional protocol then it has the option to hold on to objects to be saved even if the application is offline. When the app regains network connectivity, those objects will be persisted to the store.
 
 To turn this feature on, supply a `KCSStoreKeyUniqueOfflineSaveIdentifier` and optional `KCSStoreKeyOfflineSaveDelegate` to the options directory when creating the store.
 
 A KCSOfflineSaveStore guarantees the save will be attempted, and so persists saves to disk. If the application is terminated, the all the saved objects will be loaded the first time any time a KCSOfflineSaveStore is instantiated after the app starts, and the saves will proceed at that time. If a delegate has not yet had a chance to be set on a store, those saves will still be attempted with no notification.
 
If an object is saved multiple times from the store, the object will only be saved to the backend once, using the most recent data. It will be moved to the back of the queue each time it is saved. If a network error occurs during saving when the app connectivity is restored, it will go back into the queue in its original order. 
 @since 1.7
 */
@protocol KCSOfflineSaveStore <KCSStore>
/** An implementing store will know how many offline saves are pending.
 @return the number of offline saves waiting.
 */
- (NSUInteger) numberOfPendingSaves;
@end

/** Implementing classes get notified about a item's progress through the offline save pipeline. There can be only one delegate per store and is set when the store is created by specifying the delegate as the value for the key `KCSStoreKeyOfflineSaveDelegate` in the store options.
 @see [KCSStore storeWithOptions:]
 @since 1.7
 */
@protocol KCSOfflineSaveDelegate <NSObject>
@optional
/** This method is called before an object in the offline save queue is attempted to be saved, after the app resumes connectivity. If this method is not implemented, the object is automatically saved. This can be used to implement a timeout policy for offline saves. 
 @param entity the entity to save. Note that this may be a different object than was originally saved, but the persistable data will be the same. Be sure to implement isEqual: or check important fields for true equality.
 @param timeSaved the last time the entity was added to the queue from the store. 
 @return returnng NO will cancel the save and remove the object from the store. YES will allow the save to proceed. Not implementing this method is the same always returning YES. 
 */
- (BOOL) shouldSave:(id<KCSPersistable>)entity lastSaveTime:(NSDate*)timeSaved;
/** The delegate is notified before an object will be saved. This provides the delegate a chance to modify the object before the save. 
 @param entity the entity to save. Note that this may be a different object than was originally saved, but the persistable data will be the same. Be sure to implement isEqual: or check important fields for true equality.
 @param timeSaved the last time the entity was added to the queue from the store.
 */
- (void) willSave:(id<KCSPersistable>)entity lastSaveTime:(NSDate*)timeSaved;

/** This method is called once the save is complete. This is a good time to update the UI or notify the user, if desired.
 @param entity the object that was saved.
 */
- (void) didSave:(id<KCSPersistable>)entity;

/** This is called if the save fails. If its fails because the app is offline, the save is instead kept in the queue (with original save time) and this method is not called; otherwise it is removed from the queue. This gives the client a chance to fix the error and resave through the store.
 @param entity the object that could not be saved.
 @param error the error that occured while saving.
 */
- (void) errorSaving:(id<KCSPersistable>)entity error:(NSError*)error;
@end
