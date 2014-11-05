//
//  OPImageManager.m
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
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

#import "OPImageManager.h"
#import "OPItem.h"
#import "OPHTTPRequestOperation.h"
#import "UIImage+Resize.h"
#import "FLAnimatedImage.h"

@interface OPImageManager () {
}

@end

@implementation OPImageManager

-(id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSOperationQueue *)imageRequestOperationQueue {
    static NSOperationQueue *_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _imageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _imageRequestOperationQueue;
}

- (void) cancelImageOperationAtIndexPath:(NSIndexPath*)indexPath {
    
    NSArray* operations = [[[self class] imageRequestOperationQueue] operations];
    for (OPHTTPRequestOperation* operation in operations) {
        if ([operation.indexPath isEqual:indexPath]) {
            [operation cancel];
        }
    }
}

- (void) getImageWithRequestForItem:(OPItem*) item
                      withIndexPath:(NSIndexPath*) indexPath
                        withSuccess:(void (^)(UIImage* image))success
                        withFailure:(void (^)(void))failure {
    // if not found in cache, create request to download image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    OPHTTPRequestOperation* operation = [[OPHTTPRequestOperation alloc] initWithRequest:request];
    operation.indexPath = indexPath;
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage* image = (UIImage*) responseObject;

        // If we have a large image, resize it to
        if ((image.size.width > 2000) || (image.size.height > 2000)) {
            image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(2000.0, 2000.0) interpolationQuality:kCGInterpolationDefault];
        }
        
        // if this item url is equal to the request one - continue (avoids flashyness on fast scrolling)
        if ([item.imageUrl.absoluteString isEqualToString:request.URL.absoluteString]) {
            if (success) {
                success(image);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            NSLog(@"error getting image: %@", operation.request.URL);
            if (failure) {
                failure();
            }
        }
    }];
    [[[self class] imageRequestOperationQueue] addOperation:operation];
}



- (void) getDataWithRequestForItem:(OPItem*) item
                      withIndexPath:(NSIndexPath*) indexPath
                        withSuccess:(void (^)(NSData* data))success
                        withFailure:(void (^)(void))failure {
    // if not found in cache, create request to download image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:item.imageUrl];
    OPHTTPRequestOperation* operation = [[OPHTTPRequestOperation alloc] initWithRequest:request];
    operation.indexPath = indexPath;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // if this item url is equal to the request one - continue (avoids flashyness on fast scrolling)
        if ([item.imageUrl.absoluteString isEqualToString:request.URL.absoluteString]) {
            if (success) {
                success(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            NSLog(@"error getting data: %@", operation.request.URL);
            if (failure) {
                failure();
            }
        }
    }];
    [[[self class] imageRequestOperationQueue] addOperation:operation];
}




- (BOOL) isCellVisibleAtIndexPath:(NSIndexPath*) indexPath forCollectionView:(UICollectionView*) collectionView {
    for (NSIndexPath* thisIndexPath in collectionView.indexPathsForVisibleItems) {
        if (indexPath.item == thisIndexPath.item) {
            return YES;
        }
    }
    
    return NO;
}

- (void) loadAnimatedImageFromItem:(OPItem*) item
                       toImageView:(UIImageView*) imageView
                       atIndexPath:(NSIndexPath*) indexPath
                  onCollectionView:(UICollectionView*) cv
                   withContentMode:(UIViewContentMode)contentMode
                    withCompletion:(void (^)())completion
{
    [self getDataWithRequestForItem:item withIndexPath:indexPath withSuccess:^(NSData *data) {
        // if this cell is currently visible, continue drawing - this is for when scrolling fast (avoids flashyness)
        if ([self isCellVisibleAtIndexPath:indexPath forCollectionView:cv]) {
            // then dispatch back to the main thread to set the image
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // fade out the hourglass image
                [UIView animateWithDuration:0.25 animations:^{
                    imageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                    
                    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                    FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
                    animatedImageView.contentMode = contentMode;//UIViewContentModeScaleAspectFit;

                    animatedImageView.autoresizingMask  = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

                    animatedImageView.animatedImage = animatedImage;
                    animatedImageView.frame = imageView.frame;
                    [imageView addSubview:animatedImageView];
                    
                    // fade in image
                    [UIView animateWithDuration:0.5 animations:^{
                        imageView.alpha = 1.0;
                    } completion:^(BOOL finished) {
                        //if we have no size information yet, save the information in item, and force a re-layout
                        if (!item.size.height) {
//                            item.size = image.size;
//                            [cv.collectionViewLayout invalidateLayout];
                        }
                        
                        if (completion) {
                            completion();
                        }
                    }];
                    
                }];
            });
        }
    } withFailure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                imageView.alpha = 0.0;
            } completion:^(BOOL finished) {
                imageView.image = [UIImage imageNamed:@"image_cancel"];
                [UIView animateWithDuration:0.5 animations:^{
                    imageView.alpha = 1.0;
                }];
            }];
        });
    }];
}

- (void) loadImageFromItem:(OPItem*) item
               toImageView:(UIImageView*) imageView
               atIndexPath:(NSIndexPath*) indexPath
          onCollectionView:(UICollectionView*) cv
           withContentMode:(UIViewContentMode)contentMode
            withCompletion:(void (^)())completion
{
    for (UIView* subview in imageView.subviews) {
        [subview removeFromSuperview];
    }
    

    if ([item.imageUrl.absoluteString hasSuffix:@".gif"]) {
        [self loadAnimatedImageFromItem:item toImageView:imageView atIndexPath:indexPath onCollectionView:cv withContentMode:contentMode withCompletion:completion];
    } else {
        [self getImageWithRequestForItem:item withIndexPath:indexPath withSuccess:^(UIImage *image) {
            // if this cell is currently visible, continue drawing - this is for when scrolling fast (avoids flashyness)
            if ([self isCellVisibleAtIndexPath:indexPath forCollectionView:cv]) {
                // then dispatch back to the main thread to set the image
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // fade out the hourglass image
                    [UIView animateWithDuration:0.25 animations:^{
                        imageView.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        imageView.contentMode = contentMode;
                        imageView.image = image;
                        
                        // fade in image
                        [UIView animateWithDuration:0.5 animations:^{
                            imageView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            //if we have no size information yet, save the information in item, and force a re-layout
                            if (!item.size.height) {
                                item.size = image.size;
                                [cv.collectionViewLayout invalidateLayout];
                            }
                            
                            if (completion) {
                                completion();
                            }
                        }];
                        
                    }];
                });
            }
        } withFailure:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 animations:^{
                    imageView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    imageView.image = [UIImage imageNamed:@"image_cancel"];
                    [UIView animateWithDuration:0.5 animations:^{
                        imageView.alpha = 1.0;
                    }];
                }];
            });
        }];        
    }
}

@end
