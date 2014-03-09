//
//  KCSLinkedAppdataStore.h
//  KinveyKit
//
//  Copyright (c) 2012-2013 Kinvey. All rights reserved.
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

#import "KCSCachedStore.h"

/**
 This store will save linked resources to the backend when an entity is saved, and load such saved resources when an entity is fetched. **(This API is still in beta, please send us feedback)**. 
 
 To make use of this, have an entity map a `UIImage` property to the Kinvey dictionary in - [KCSPersistable hostToKinveyPropertyMapping], and save that entity. The associated image will be saved a a PNG blob in the backend and linked back to its entity, so that when the entity is loaded, the image will be fetched from the resource service.
 
 KCSLinkedAppdataStore also saves/loads object graphs specified through special Kinvey References. This information is stored on the backend, and is created when an object specifies a kinveyPropertyToCollectionMapping. Properties that have been mapped to foreign (or the same) collection will have the relation along with the linked objects persisted to the backend. Using [KCSStore queryWithQuery:withCompletionBlock:withProgressBlock:] and [KCSAppdataStore loadObjectWithID:withCompletionBlock:withProgressBlock:] will have the reference objects loaded and instantiated at that time. See our online iOS Developer Guide for more details, examples, and limations [http://docs.kinvey.com/ios-developers-guide.html](http://docs.kinvey.com/ios-developers-guide.html).
 
 If offline saving is enabled (see KCSCachedStore and KCSOfflineSaveStore), then linked resources are only saved if the app is online when the save method is called. From the offline save mode, only the appdata portion is persisted, the linked resource will not be saved.
 
 @since 1.5
 */
@interface KCSLinkedAppdataStore : KCSCachedStore

@end
