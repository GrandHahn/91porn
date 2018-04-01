//
//  CTScrollBarView.m
//  testForTitleBarScroll
//
//  Created by Hahn on 2017/12/27.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTScrollBarView.h"
#import "CTScrollTitleBar.h"
#import "UIView+Frame.h"

@interface CTScrollBarView () <CTScrollTitleBarDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) CTScrollTitleBar *bar;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation CTScrollBarView

#pragma mark - life cycle
+ (instancetype)barViewWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andDelegate:(id<CTScrollBarViewDelegate>)delegate {
    if (![titleArray isKindOfClass:[NSArray class]] || 0 == titleArray.count) {
        NSLog(@"init error");
        return nil;
    }
    CTScrollBarView *barView = [[self alloc] initWithFrame:frame];
    barView.titleArray = titleArray;
    barView.delegate = delegate;
    [barView setupUI];
    return barView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bar.frame = CGRectMake(0, 0, self.width, 35);
    self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.bar.frame), self.width, self.height - self.bar.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.titleArray.count, self.scrollView.height);
    if (self.lazyLoad) {
        UIView *view = [self getViewFromDelegateAtIndex:0];
        view.frame = CGRectMake(self.scrollView.width * 0, 0, self.scrollView.width, self.scrollView.height);
        [self.scrollView addSubview:view];
    } else {
        for (int i = 0; i < self.titleArray.count; i++) {
            UIView *view = [self getViewFromDelegateAtIndex:i];
            view.frame = CGRectMake(self.scrollView.width * i, 0, self.scrollView.width, self.scrollView.height);
            [self.scrollView addSubview:view];
        }
    }
}

#pragma mark - UI
- (void)setupUI {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self setupScrollTitleBar];
    [self setupScrollView];
}

- (void)setupScrollTitleBar {
    CTScrollTitleBar *bar = [[CTScrollTitleBar alloc] initWithFrame:CGRectZero andTitleArray:[self.titleArray copy]];
    [self addSubview:bar];
    self.bar = bar;
    bar.delegate = self;
}

- (void)setupScrollView {
    UIScrollView *scrollV = [[UIScrollView alloc] init];
    [self addSubview:scrollV];
    self.scrollView = scrollV;
    scrollV.pagingEnabled = YES;
    scrollV.showsHorizontalScrollIndicator = NO;
    scrollV.delegate = self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.scrollView isEqual:scrollView]) {
        NSInteger index = scrollView.contentOffset.x / self.scrollView.width;
        [self.bar scrollToIndex:index];
        if (self.lazyLoad) {
            [self addChildViewToScrollViewWithIndex:index];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.scrollView isEqual:scrollView] && scrollView.isDragging) {
        NSInteger index = scrollView.contentOffset.x / self.scrollView.width + 0.5;
        if (index < 0) index = 0;
        if (index > self.titleArray.count - 1) index = self.titleArray.count - 1;
        [self.bar scrollToIndex:index];
    }
}

#pragma mark - CTScrollTitleBarDelegate
- (void)scrollTitleBar:(CTScrollTitleBar *)bar didClickIndex:(NSInteger)index {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * index, 0) animated:YES];
    [self addChildViewToScrollViewWithIndex:index];
}

#pragma mark - other
- (void)addChildViewToScrollViewWithIndex:(NSInteger)index {
    UIView *view = [self getViewFromDelegateAtIndex:index];
    // 只添加一次
    if (![view.superview isEqual:self.scrollView]) {
        view.frame = CGRectMake(self.scrollView.width * index, 0, self.scrollView.width, self.scrollView.height);
        [self.scrollView addSubview:view];
    }
}

- (UIView *)getViewFromDelegateAtIndex:(NSInteger)index {
    UIView *view = nil;
    if ([self.delegate respondsToSelector:@selector(scrollBarView:viewAtIndex:)]) {
        view = [self.delegate scrollBarView:self viewAtIndex:index];
    }
    BOOL hasView = [view isKindOfClass:[UIView class]];
    if (hasView) {
        return view;
    } else {
        return nil;
    }
}

@end
