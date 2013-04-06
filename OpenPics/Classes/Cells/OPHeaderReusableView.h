//
//  OPHeaderReusableView.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OPHeaderDelegate <NSObject>
- (void) doSearchWithQuery:(NSString*) queryString;
@end

@interface OPHeaderReusableView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UITextField *internalTextField;
@property (strong,nonatomic) id delegate;

- (IBAction)searchTapped:(id)sender;

@end
