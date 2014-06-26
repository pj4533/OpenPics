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
#import "OPItem.h"
#import "OPScrollView.h"

@protocol OPContentCellDelegate <NSObject>
@optional
- (void) singleTappedCell;
- (void) showProgressWithBytesRead:(NSUInteger) bytesRead
                withTotalBytesRead:(NSInteger) totalBytesRead
      withTotalBytesExpectedToRead:(NSInteger) totalBytesExpectedToRead;
@end


@class OPProvider;
@interface OPContentCell : UICollectionViewCell

// used for zooming of image
@property (weak, nonatomic) IBOutlet OPScrollView *internalScrollView;

@property (weak, nonatomic) OPItem* item;
@property (weak, nonatomic) OPProvider* provider;

@property (weak, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id delegate;

- (void) setupForSingleImageLayoutAnimated:(BOOL) animated;

@end
