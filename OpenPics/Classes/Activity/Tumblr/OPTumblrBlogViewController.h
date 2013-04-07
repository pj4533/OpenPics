//
//  LPTumblrBlogVC.h
//
//  Created by PJ Gray on 4/16/12.
//  Copyright (c) 2012 Say Goodnight Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OPTumblrBlogDelegate <NSObject>
- (void) didSelectBlogWithHostName:(NSString*) blogHostName;
@end

@interface OPTumblrBlogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tumblrBlogTable;
@property (strong, nonatomic) NSArray *blogs;
@property (strong, nonatomic) id delegate;

@end
