// OPFlickrCommonsProvider.m
// 
// Copyright (c) 2013 Say Goodnight Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OPFlickrProvider.h"
#import "AFFlickrSessionManager.h"
#import "OPItem.h"
#import "OPProviderTokens.h"



@interface OPFlickrProvider () {
    NSDictionary* _buddyicons;
}

@end

@implementation OPFlickrProvider

- (id) initWithProviderType:(NSString*) providerType {
    self = [super initWithProviderType:providerType];
    if (self) {
        _buddyicons = @{
                        
                        @"104959762@N04" : @"https://farm8.staticflickr.com/7356/buddyicons/104959762@N04_r.jpg",
                        @"124327652@N02" : @"https://farm3.staticflickr.com/2905/buddyicons/124327652@N02_r.jpg",
                        @"56434318@N05" : @"https://farm4.staticflickr.com/3825/buddyicons/56434318@N05_l.jpg",
                        @"76602844@N05" : @"https://farm9.staticflickr.com/8533/buddyicons/76602844@N05_l.jpg",
                        @"108745105@N04" : @"https://farm4.staticflickr.com/3670/buddyicons/108745105@N04_l.jpg",
                        @"60147353@N07" : @"https://farm8.staticflickr.com/7320/buddyicons/60147353@N07_l.jpg",
                        @"107895189@N03" : @"https://farm4.staticflickr.com/3709/buddyicons/107895189@N03_l.jpg",
                        @"108605878@N06" : @"https://farm6.staticflickr.com/5537/buddyicons/108605878@N06_r.jpg",
                        @"26491575@N05" : @"https://farm3.staticflickr.com/2852/buddyicons/26491575@N05_r.jpg",
                        @"95711690@N03" : @"https://farm8.staticflickr.com/7378/buddyicons/95711690@N03_r.jpg",
                        @"31033598@N03" : @"https://farm6.staticflickr.com/5479/buddyicons/31033598@N03_l.jpg",
                        @"12403504@N02" : @"https://farm8.staticflickr.com/7437/buddyicons/12403504@N02_r.jpg",
                        @"109550159@N08" : @"https://farm3.staticflickr.com/2811/buddyicons/109550159@N08_r.jpg",
                        @"99915476@N04" : @"https://farm8.staticflickr.com/7307/buddyicons/99915476@N04_l.jpg",
                        @"48220291@N04" : @"https://farm5.staticflickr.com/4072/buddyicons/48220291@N04.jpg",
                        @"69269002@N04" : @"https://farm4.staticflickr.com/3801/buddyicons/69269002@N04_r.jpg",
                        @"88669438@N03" : @"https://farm3.staticflickr.com/2851/buddyicons/88669438@N03_l.jpg",
                        @"99278405@N04" : @"https://farm4.staticflickr.com/3708/buddyicons/99278405@N04.jpg",
                        @"99902797@N03" : @"https://farm8.staticflickr.com/7460/buddyicons/99902797@N03_l.jpg",
                        @"95772747@N07" : @"https://farm4.staticflickr.com/3793/buddyicons/95772747@N07_r.jpg",
                        @"48641766@N05" : @"https://farm3.staticflickr.com/2904/buddyicons/48641766@N05_l.jpg",
                        @"95520404@N07" : @"https://farm4.staticflickr.com/3777/buddyicons/95520404@N07_r.jpg",
                        @"94021017@N05" : @"https://farm6.staticflickr.com/5535/buddyicons/94021017@N05_r.jpg",
                        @"47154409@N06" : @"https://farm6.staticflickr.com/5497/buddyicons/47154409@N06_r.jpg",
                        @"77015680@N05" : @"https://farm6.staticflickr.com/5324/buddyicons/77015680@N05_r.jpg",
                        @"39758725@N03" : @"https://farm6.staticflickr.com/5492/buddyicons/39758725@N03_m.jpg",
                        @"95717549@N07" : @"https://farm8.staticflickr.com/7458/buddyicons/95717549@N07_r.jpg",
                        @"52529054@N06" : @"https://farm6.staticflickr.com/5530/buddyicons/52529054@N06_r.jpg",
                        @"38561291@N04" : @"https://farm6.staticflickr.com/5450/buddyicons/38561291@N04_l.jpg",
                        @"27331537@N06" : @"https://farm8.staticflickr.com/7292/buddyicons/27331537@N06_r.jpg",
                        @"61232251@N05" : @"https://farm6.staticflickr.com/5456/buddyicons/61232251@N05_r.jpg",
                        @"54403180@N04" : @"https://farm8.staticflickr.com/7371/buddyicons/54403180@N04_r.jpg",
                        @"23121382@N07" : @"https://farm4.staticflickr.com/3809/buddyicons/23121382@N07_l.jpg",
                        @"62173425@N02" : @"https://farm7.staticflickr.com/6199/buddyicons/62173425@N02.jpg",
                        @"67193564@N03" : @"https://farm3.staticflickr.com/2849/buddyicons/67193564@N03_r.jpg",
                        @"59811348@N05" : @"https://farm6.staticflickr.com/5060/buddyicons/59811348@N05.jpg",
                        @"45270502@N06" : @"https://farm4.staticflickr.com/3815/buddyicons/45270502@N06_l.jpg",
                        @"61498590@N03" : @"https://farm7.staticflickr.com/6149/buddyicons/61498590@N03.jpg",
                        @"47290943@N03" : @"https://farm6.staticflickr.com/5468/buddyicons/47290943@N03_l.jpg",
                        @"29295370@N07" : @"https://farm3.staticflickr.com/2861/buddyicons/29295370@N07_r.jpg",
                        @"49487266@N07" : @"https://farm5.staticflickr.com/4070/buddyicons/49487266@N07.jpg",
                        @"47908901@N03" : @"https://farm3.staticflickr.com/2751/buddyicons/47908901@N03.jpg",
                        @"41815917@N06" : @"https://farm3.staticflickr.com/2495/buddyicons/41815917@N06.jpg",
                        @"44494372@N05" : @"https://farm3.staticflickr.com/2923/buddyicons/44494372@N05_r.jpg",
                        @"14456531@N07" : @"https://farm2.staticflickr.com/1223/buddyicons/14456531@N07.jpg",
                        @"9189488@N02" : @"https://farm6.staticflickr.com/5459/buddyicons/9189488@N02_l.jpg",
                        @"25960495@N06" : @"https://farm6.staticflickr.com/5442/buddyicons/25960495@N06_l.jpg",
                        @"37547255@N08" : @"https://farm4.staticflickr.com/3580/buddyicons/37547255@N08.jpg",
                        @"30515687@N05" : @"https://farm5.staticflickr.com/4068/buddyicons/30515687@N05.jpg",
                        @"33147718@N05" : @"https://farm4.staticflickr.com/3829/buddyicons/33147718@N05_l.jpg",
                        @"41131493@N06" : @"https://farm3.staticflickr.com/2886/buddyicons/41131493@N06_r.jpg",
                        @"47326604@N02" : @"https://farm5.staticflickr.com/4066/buddyicons/47326604@N02.jpg",
                        @"36988361@N08" : @"https://farm4.staticflickr.com/3425/buddyicons/36988361@N08.jpg",
                        @"37784107@N08" : @"https://farm5.staticflickr.com/4003/buddyicons/37784107@N08.jpg",
                        @"48143042@N05" : @"https://farm5.staticflickr.com/4066/buddyicons/48143042@N05.jpg",
                        @"31575009@N05" : @"https://farm8.staticflickr.com/7325/buddyicons/31575009@N05_l.jpg",
                        @"8337233@N06" : @"https://farm3.staticflickr.com/2913/buddyicons/8337233@N06_r.jpg",
                        @"35740357@N03" : @"https://farm9.staticflickr.com/8547/buddyicons/35740357@N03_r.jpg",
                        @"37381115@N04" : @"https://farm4.staticflickr.com/3354/buddyicons/37381115@N04.jpg",
                        @"35128489@N07" : @"https://farm8.staticflickr.com/7369/buddyicons/35128489@N07_l.jpg",
                        @"36281769@N04" : @"https://farm4.staticflickr.com/3655/buddyicons/36281769@N04.jpg",
                        @"23686862@N03" : @"https://farm4.staticflickr.com/3707/buddyicons/23686862@N03_r.jpg",
                        @"35532303@N08" : @"https://farm4.staticflickr.com/3646/buddyicons/35532303@N08.jpg",
                        @"37199428@N06" : @"https://farm4.staticflickr.com/3564/buddyicons/37199428@N06.jpg",
                        @"35310696@N04" : @"https://farm4.staticflickr.com/3306/buddyicons/35310696@N04.jpg",
                        @"36038586@N04" : @"https://farm4.staticflickr.com/3567/buddyicons/36038586@N04.jpg",
                        @"34419668@N08" : @"https://farm8.staticflickr.com/7395/buddyicons/34419668@N08_l.jpg",
                        @"34101160@N07" : @"https://farm4.staticflickr.com/3456/buddyicons/34101160@N07.jpg",
                        @"34586311@N05" : @"https://farm3.staticflickr.com/2835/buddyicons/34586311@N05_r.jpg",
                        @"31846825@N04" : @"https://farm3.staticflickr.com/2854/buddyicons/31846825@N04_l.jpg",
                        @"32605636@N06" : @"https://farm8.staticflickr.com/7441/buddyicons/32605636@N06_l.jpg",
                        @"30835311@N07" : @"https://farm8.staticflickr.com/7362/buddyicons/30835311@N07_r.jpg",
                        @"32951986@N05" : @"https://farm4.staticflickr.com/3225/buddyicons/32951986@N05.jpg",
                        @"32741315@N06" : @"https://farm4.staticflickr.com/3285/buddyicons/32741315@N06.jpg",
                        @"32300107@N06" : @"https://farm6.staticflickr.com/5535/buddyicons/32300107@N06_l.jpg",
                        @"30115723@N02" : @"https://farm9.staticflickr.com/8270/buddyicons/30115723@N02_l.jpg",
                        @"29998366@N02" : @"https://farm3.staticflickr.com/2853/buddyicons/29998366@N02_l.jpg",
                        @"25786829@N08" : @"https://farm6.staticflickr.com/5331/buddyicons/25786829@N08_l.jpg",
                        @"30194653@N06" : @"https://farm4.staticflickr.com/3717/buddyicons/30194653@N06_l.jpg",
                        @"29454428@N08" : @"https://farm9.staticflickr.com/8544/buddyicons/29454428@N08_r.jpg",
                        @"11334970@N05" : @"https://farm2.staticflickr.com/1393/buddyicons/11334970@N05.jpg",
                        @"26808453@N03" : @"https://farm9.staticflickr.com/8189/buddyicons/26808453@N03.jpg",
                        @"26577438@N06" : @"https://farm4.staticflickr.com/3017/buddyicons/26577438@N06.jpg",
                        @"7167652@N06" : @"https://farm1.staticflickr.com/156/buddyicons/7167652@N06.jpg",
                        @"26134435@N05" : @"https://farm4.staticflickr.com/3199/buddyicons/26134435@N05.jpg",
                        @"25053835@N03" : @"https://farm3.staticflickr.com/2282/buddyicons/25053835@N03.jpg",
                        @"24785917@N03" : @"https://farm8.staticflickr.com/7409/buddyicons/24785917@N03_r.jpg",
                        @"8623220@N02" : @"https://farm4.staticflickr.com/3703/buddyicons/8623220@N02_l.jpg"
                        
                        };
}
    return self;
}

- (BOOL) isConfigured {
#ifndef kOPPROVIDERTOKEN_FLICKR
#warning *** WARNING: Make sure you have added your Flickr token to OPProviderTokens.h!
    return NO;
#else
    return YES;
#endif
}

- (void) doInitialSearchWithUserId:(NSString*)userId
                         isCommons:(BOOL)isCommons
                           success:(void (^)(NSArray* items, BOOL canLoadMore))success
                           failure:(void (^)(NSError* error))failure {
    
    [self getItemsWithQuery:@""
             withPageNumber:@1
                 withUserId:userId
                  isCommons:isCommons
                    success:success
                    failure:failure];
}

- (NSString*) getHighestResUrlFromDictionary:(NSDictionary*) dict {
    if (dict[@"url_l"]) {
        return dict[@"url_l"];
    } else if (dict[@"url_m"]) {
        return dict[@"url_m"];
    } else if (dict[@"url_s"]) {
        return dict[@"url_s"];
    }
    
    return nil;
}

- (void) getImageSetsWithPageNumber:(NSNumber*) pageNumber
                         withUserId:(NSString*) userId
                            success:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    NSMutableDictionary* parameters = @{
                                        @"page": pageNumber,
                                        @"nojsoncallback": @"1",
                                        @"method" : @"flickr.photosets.getlist",
                                        @"format" : @"json",
                                        @"primary_photo_extras": @"url_m,url_s",
                                        @"per_page": @"20"
                                        }.mutableCopy;
    
    if (userId) {
        parameters[@"user_id"] = userId;
    }
    
    [[AFFlickrSessionManager sharedClient] GET:@"services/rest" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSDictionary* photosetsDict = responseObject[@"photosets"];
        NSMutableArray* retArray = [NSMutableArray array];
        NSArray* photosetArray = photosetsDict[@"photoset"];
        for (NSDictionary* itemDict in photosetArray) {
            NSString* imageUrlString = [self getHighestResUrlFromDictionary:itemDict[@"primary_photo_extras"]];
            NSMutableDictionary* opImageDict = @{
                                                 @"imageUrl": [NSURL URLWithString:imageUrlString],
                                                 @"title" : [itemDict valueForKeyPath:@"title._content"],
                                                 @"providerType": self.providerType,
                                                 @"providerSpecific": itemDict,
                                                 @"isImageSet": @YES
                                                 }.mutableCopy;
            
            if ([itemDict valueForKeyPath:@"primary_photo_extras.width_o"]) {
                opImageDict[@"width"] = [itemDict valueForKeyPath:@"primary_photo_extras.width_o"];
            }
            if ([itemDict valueForKeyPath:@"primary_photo_extras.height_o"]) {
                opImageDict[@"height"] = [itemDict valueForKeyPath:@"primary_photo_extras.height_o"];
            }
            
            OPItem* item = [[OPItem alloc] initWithDictionary:opImageDict];
            [retArray addObject:item];
        }
        
        BOOL returnCanLoadMore = NO;
        NSInteger thisPage = [photosetsDict[@"page"] integerValue];
        NSInteger totalPages = [photosetsDict[@"pages"] integerValue];
        if (thisPage < totalPages) {
            returnCanLoadMore = YES;
        }
        
        if (success) {
            success(retArray,returnCanLoadMore);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) parseResponseDictionary:(NSDictionary*) dict
                         success:(void (^)(NSArray* items, BOOL canLoadMore))success {
    NSArray* photoArray = dict[@"photo"];
    NSMutableArray* retArray = @[].mutableCopy;
    for (NSDictionary* itemDict in photoArray) {
        NSString* farmId = itemDict[@"farm"];
        NSString* serverId = itemDict[@"server"];
        NSString* photoId = itemDict[@"id"];
        NSString* photoSecret = itemDict[@"secret"];
        
        NSString* imageUrlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",farmId,serverId,photoId,photoSecret];
        NSMutableDictionary* opImageDict = @{
                                             @"imageUrl": [NSURL URLWithString:imageUrlString],
                                             @"title" : itemDict[@"title"],
                                             @"providerType": self.providerType,
                                             @"providerSpecific": itemDict,
                                             }.mutableCopy;
        
        if (itemDict[@"width_o"]) {
            opImageDict[@"width"] = itemDict[@"width_o"];
        }
        if (itemDict[@"height_o"]) {
            opImageDict[@"height"] = itemDict[@"height_o"];
        }
        
        OPItem* item = [[OPItem alloc] initWithDictionary:opImageDict];
        [retArray addObject:item];
    }
    
    BOOL returnCanLoadMore = NO;
    NSInteger thisPage = [dict[@"page"] integerValue];
    NSInteger totalPages = [dict[@"pages"] integerValue];
    if (thisPage < totalPages) {
        returnCanLoadMore = YES;
    }
    
    if (success) {
        success(retArray,returnCanLoadMore);
    }
}

- (void) getInstitutionsWithSuccess:(void (^)(NSArray* items, BOOL canLoadMore))success
                            failure:(void (^)(NSError* error))failure {
    NSMutableDictionary* parameters = @{
                                        @"nojsoncallback": @"1",
                                        @"method" : @"flickr.commons.getinstitutions",
                                        @"format" : @"json"
                                        }.mutableCopy;
    
    [[AFFlickrSessionManager sharedClient] GET:@"services/rest" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary* institutionsDict = responseObject[@"institutions"];
        NSArray* institutionArray = institutionsDict[@"institution"];
        NSMutableArray* retArray = @[].mutableCopy;
        for (NSDictionary* itemDict in institutionArray) {
            NSString* nsid = itemDict[@"nsid"];
            
            
            NSString* imageUrlString = [NSString stringWithFormat:@"https://flickr.com/buddyicons/%@.jpg",nsid];
            
            if (_buddyicons[nsid]) {
                imageUrlString = _buddyicons[nsid];
            }
            
            
            NSString* instName = @"";
            if ([itemDict valueForKeyPath:@"name._content"]) {
                instName = [itemDict valueForKeyPath:@"name._content"];
            }
            NSMutableDictionary* opImageDict = @{
                                                 @"imageUrl": [NSURL URLWithString:imageUrlString],
                                                 @"title" : instName,
                                                 @"providerType": self.providerType,
                                                 @"providerSpecific": itemDict,
                                                 @"isImageSet": @YES
                                                 }.mutableCopy;
            
            OPItem* item = [[OPItem alloc] initWithDictionary:opImageDict];
            [retArray addObject:item];
        }
        
        if (success) {
            success(retArray,NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
    
}

- (void) getItemsInSetWithId:(NSString*) setId
              withPageNumber:(NSNumber*) pageNumber
                     success:(void (^)(NSArray* items, BOOL canLoadMore))success
                     failure:(void (^)(NSError* error))failure {
    NSMutableDictionary* parameters = @{
                                        @"photoset_id": setId,
                                        @"page": pageNumber,
                                        @"nojsoncallback": @"1",
                                        @"method" : @"flickr.photosets.getphotos",
                                        @"format" : @"json",
                                        @"extras": @"url_b,url_o,o_dims,url_l",
                                        @"per_page": @"20"
                                        }.mutableCopy;
    
    [[AFFlickrSessionManager sharedClient] GET:@"services/rest" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary* photosDict = responseObject[@"photoset"];
        [self parseResponseDictionary:photosDict success:success];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) getItemsWithQuery:(NSString*) queryString
            withPageNumber:(NSNumber*) pageNumber
                withUserId:(NSString*) userId
                 isCommons:(BOOL)isCommons
                   success:(void (^)(NSArray* items, BOOL canLoadMore))success
                   failure:(void (^)(NSError* error))failure {
    
    NSMutableDictionary* parameters = @{
                                 @"text" : queryString,
                                 @"page": pageNumber,
                                 @"nojsoncallback": @"1",
                                 @"method" : @"flickr.photos.search",
                                 @"format" : @"json",
                                 @"extras": @"url_b,url_o,o_dims,url_l",
                                 @"per_page": @"20"
                                 }.mutableCopy;
    
    if (isCommons) {
        parameters[@"is_commons"] = @"true";
    }
    
    if (userId) {
        parameters[@"user_id"] = userId;
    }
    
    [[AFFlickrSessionManager sharedClient] GET:@"services/rest" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary* photosDict = responseObject[@"photos"];
        [self parseResponseDictionary:photosDict success:success];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"ERROR: %@\n%@\n%@", error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
    }];
}

- (void) upRezItem:(OPItem *) item withCompletion:(void (^)(NSURL *uprezImageUrl, OPItem* item))completion {

    NSString* upRezzedUrlString = item.imageUrl.absoluteString;
    
    if (item.providerSpecific[@"url_o"]) {
        upRezzedUrlString = item.providerSpecific[@"url_o"];
    } else if (item.providerSpecific[@"url_b"]) {
        upRezzedUrlString = item.providerSpecific[@"url_b"];
    } else if (item.providerSpecific[@"url_l"]) {
        upRezzedUrlString = item.providerSpecific[@"url_l"];
    }

    if (completion && ![upRezzedUrlString isEqualToString:item.imageUrl.absoluteString]) {
        completion([NSURL URLWithString:upRezzedUrlString], item);
    }
}

@end
