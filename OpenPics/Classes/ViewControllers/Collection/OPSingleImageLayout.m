//
//  OPSingleImageLayout.m
//
//  Created by PJ Gray on 1/30/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

#import "OPSingleImageLayout.h"

@implementation OPSingleImageLayout
-(id)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // this code basically just goes right or left 1 cell if the velocity is over or under 1/-1
    NSArray* visibleItems = self.collectionView.indexPathsForVisibleItems;
    NSIndexPath* originalPath = [visibleItems objectAtIndex:0];
    for (NSIndexPath* thisPath in visibleItems) {
        
        if (velocity.x < 0) {
            if (thisPath.row > originalPath.row)
                originalPath = thisPath;
        } else {
            if (thisPath.row < originalPath.row)
                originalPath = thisPath;
        }
    }
    
    UICollectionViewLayoutAttributes* attrs = [self layoutAttributesForItemAtIndexPath:originalPath];
    if (velocity.x > 1.0) {
        return CGPointMake(attrs.frame.origin.x+self.collectionView.bounds.size.width, proposedContentOffset.y);
    } else if (velocity.x < -1.0){
        return CGPointMake(attrs.frame.origin.x-self.collectionView.bounds.size.width, proposedContentOffset.y);
    }
    
    
    
    // this is from the Line WWDC sample - for handling the low velocity case
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
