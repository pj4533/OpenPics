//
//  OPProviderTableViewController.h
//  OpenPics
//
//  Created by PJ Gray on 7/12/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPProvider;

@protocol OPProviderTableDelegate <NSObject>
- (void) tappedProvider:(OPProvider*) provider;
@end

@interface OPProviderTableViewController : UITableViewController

@property (strong, nonatomic) id delegate;

@end
