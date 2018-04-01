//
//  CTPhotoBrowserCollectionLayout.m
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/22.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTPhotoBrowserCollectionLayout.h"

@implementation CTPhotoBrowserCollectionLayout
- (void)prepareLayout {
    // 设置布局属性
    self.itemSize = self.collectionView.bounds.size;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 设置collectionView属性
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
}
@end
