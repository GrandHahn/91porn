//
//  CTPhotoBrowserAnimator.m
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/23.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTPhotoBrowserAnimator.h"

@interface CTPhotoBrowserAnimator () <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent;

@end

@implementation CTPhotoBrowserAnimator

#pragma mark - UIViewControllerTransitioningDelegate
// 弹出动画谁管理
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isPresent = YES;
    return self;
}


// 消失动画谁管理
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresent = NO;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
// 动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.isPresent ? [self animateForPresentView:transitionContext] : [self animateForDismissView:transitionContext];
}

- (void)animateForPresentView:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 将弹出的view
    UIView *presentView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    // 添加
    [[transitionContext containerView] addSubview:presentView];
    
    if (self.presentDelegate == nil) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    // 初始位置
    UIImageView *imageView = [self.presentDelegate imageViewForPresent:self.indexOfImageWillShow];
    [[transitionContext containerView] addSubview:imageView];
    
    NSInteger currentIndex = self.indexOfImageWillShow;
    
    imageView.frame = [self.presentDelegate startRect:currentIndex];
    // 动画
    presentView.alpha = 0;
    [transitionContext containerView].backgroundColor = [UIColor blackColor];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        imageView.frame = [self.presentDelegate endRect:currentIndex];
    } completion:^(BOOL finished) {
        presentView.alpha = 1.0;
        [imageView removeFromSuperview];
        [transitionContext containerView].backgroundColor = [UIColor clearColor];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateForDismissView:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 将消失的view
    UIView *dismissView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [dismissView removeFromSuperview];
    
    if (self.presentDelegate == nil || self.dismissDelegate == nil) {
        [transitionContext completeTransition:YES];
        return;
    }
    
    UIImageView *imageView = [self.dismissDelegate imageViewForDismiss];
    [[transitionContext containerView] addSubview:imageView];
    
    NSInteger currentIndex = [self.dismissDelegate currentIndex];
    // 初始位置
    CGRect endRect = [self.presentDelegate endRect:currentIndex];
    CGRect startRect = [self.presentDelegate startRect:currentIndex];
    if (CGRectEqualToRect(endRect, CGRectZero) && CGRectEqualToRect(startRect, CGRectZero)) { // 当endRect、startRect都为CGRectZero时，只做透明渐变
        
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        blackView.backgroundColor = [UIColor blackColor];
        [blackView addSubview:imageView];
        [[transitionContext containerView] addSubview:blackView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            blackView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        
        imageView.frame = [self.presentDelegate endRect:currentIndex];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            imageView.frame = [self.presentDelegate startRect:currentIndex];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
