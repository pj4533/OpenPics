//
//  OPContentCell.h
//
//  Created by PJ Gray on 2/10/13.
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


#import <UIKit/UIKit.h>
#import "OPImageItem.h"
#import "OPScrollView.h"
#import "OPViewController.h"


@class OPProvider;
@interface OPContentCell : UICollectionViewCell <UIActivityItemSource>

@property (strong, nonatomic) IBOutlet OPScrollView *internalScrollView;
@property (strong, nonatomic) OPImageItem* item;
@property (strong, nonatomic) OPProvider* provider;

@property (strong, nonatomic) IBOutlet UIView *backBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *shareBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *favoriteBackgroundView;

@property (strong, nonatomic) IBOutlet UIImageView *favoriteButtonImageView;
@property (strong, nonatomic) IBOutlet UILabel *favoriteButtonLabel;

@property (strong, nonatomic) OPViewController* mainViewController;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property BOOL showingUI;

//- (IBAction)backTapped:(id)sender;
//- (IBAction)shareTapped:(id)sender;
//- (IBAction)favoriteTapped:(id)sender;

- (void) fadeOutUIWithCompletion:(void (^)(BOOL finished))completion;
- (void) fadeInUIWithCompletion:(void (^)(BOOL finished))completion;

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated;
//- (void) setupForGridLayout;


@end
