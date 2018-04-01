//
//  CTPhotoBrowserAnimator.h
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/23.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTPresentDelegate <NSObject>

- (CGRect)startRect:(NSInteger)index;
- (CGRect)endRect:(NSInteger)index;
- (UIImageView *)imageViewForPresent:(NSInteger)index;

@end

@protocol CTDismissDelegate <NSObject>

- (NSInteger)currentIndex;
- (UIImageView *)imageViewForDismiss;

@end

@interface CTPhotoBrowserAnimator : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) id<CTPresentDelegate> presentDelegate;
@property (nonatomic, weak) id<CTDismissDelegate> dismissDelegate;

/** 弹出时展示第几张图片。默认0。 */
@property (nonatomic, assign) NSInteger indexOfImageWillShow;

@end
