//
//  OPHTTPRequestOperation.h
//  OpenPics
//
//  Created by PJ Gray on 6/24/14.
//  Copyright (c) 2014 Say Goodnight Software. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface OPHTTPRequestOperation : AFHTTPRequestOperation

@property (weak, nonatomic) NSIndexPath* indexPath;

@end
