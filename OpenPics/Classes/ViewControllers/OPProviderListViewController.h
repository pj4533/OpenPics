//
//  OPProviderListViewController.h
//  OpenPics
//
//  Created by PJ Gray on 4/6/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPProvider;

@protocol OPProviderListDelegate <NSObject>
- (void) tappedProvider:(OPProvider*) provider;
@end

@interface OPProviderListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *internalTableView;
@property (strong, nonatomic) id delegate;

@end
