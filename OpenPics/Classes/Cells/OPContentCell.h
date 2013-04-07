//
//  OPContentCell.h
//
//  Created by PJ Gray on 2/10/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPImageItem.h"
#import "OPScrollView.h"
#import "OPViewController.h"



@interface OPContentCell : UICollectionViewCell <UIActivityItemSource>

@property (strong, nonatomic) IBOutlet OPScrollView *internalScrollView;
@property (strong, nonatomic) OPImageItem* item;

@property (strong, nonatomic) IBOutlet UIView *backBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *shareBackgroundView;


@property (strong, nonatomic) OPViewController* mainViewController;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UIView *completedView;
@property (strong, nonatomic) IBOutlet UILabel *completedViewLabel;

@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property BOOL showingUI;

- (IBAction)backTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;

- (void) fadeOutUIWithCompletion:(void (^)(BOOL finished))completion;
- (void) fadeInUIWithCompletion:(void (^)(BOOL finished))completion;

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated;
- (void) setupForGridLayout;


@end
