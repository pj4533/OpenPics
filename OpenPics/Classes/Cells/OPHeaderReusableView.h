//
//  OPHeaderReusableView.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPProvider;

@protocol OPHeaderDelegate <NSObject>
- (void) doSearchWithQuery:(NSString*) queryString;
- (void) flipToMap;
- (void) providerTappedFromRect:(CGRect) rect inView:(UIView*)view;
@end

@interface OPHeaderReusableView : UICollectionReusableView <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *internalTextField;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) IBOutlet UIButton *providerButton;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;

- (IBAction)searchTapped:(id)sender;
- (IBAction)providerTapped:(id)sender;
- (IBAction)mapTapped:(id)sender;

@end
