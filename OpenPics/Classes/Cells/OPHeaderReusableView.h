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
- (void) providerTappedFromRect:(CGRect) rect;
@end

@interface OPHeaderReusableView : UICollectionReusableView <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *internalTextField;
@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) IBOutlet UIButton *providerButton;

- (IBAction)searchTapped:(id)sender;
- (IBAction)providerTapped:(id)sender;

@end
