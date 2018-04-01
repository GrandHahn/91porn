//
//  CTScrollTitleBar.m
//  testForTitleBarScroll
//
//  Created by Hahn on 2017/12/26.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTScrollTitleBar.h"
#import "UIView+Frame.h"

@interface CTScrollTitleBar ()

@property (nonatomic, weak) UIView *titleBar;
@property (nonatomic, weak) UIButton *previousClickedtitleButton;
@property (nonatomic, weak) UIScrollView *scrollV;
@property (nonatomic, weak) UIView *downLine;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation CTScrollTitleBar

- (void)scrollToIndex:(NSInteger)index {
    if (index >= self.titleArray.count) {
        index = self.titleArray.count - 1;
    }
    if (index < 0) {
        index = 0;
    }
    if (0 == self.titleArray.count) {
        return;
    }
    [self changeStatusToButton:self.buttonArray[index] withAnim:YES];
// modified for scroll enable
    [self scrollToCenterOfButton:self.buttonArray[index]];
}

#pragma mark - lazy load
- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray {
    if (nil == titleArray || 0 == titleArray.count) {
        NSLog(@"CTScrollTitleBar init error:need a titleArray.");
        return nil;
    }
    if (self = [super initWithFrame:frame]) {
        self.titleArray = titleArray;
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

#pragma mark - UI
- (void)setupUI {
    [self setupTitleBar];
    [self setupTitleBtn];
    [self setupDownLine];
}

- (void)setupTitleBar {
//    UIView *titleBar = [[UIView alloc] init];
// modified for scroll enable
    UIScrollView *titleBar = [[UIScrollView alloc] init];
    titleBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:titleBar];
    self.titleBar = titleBar;
    titleBar.backgroundColor = [UIColor whiteColor];
}

- (void)setupTitleBtn {
    NSArray *titleArray = self.titleArray;
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [titleBtn setTitle:titleArray[i] forState:UIControlStateNormal];
//        titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [titleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor colorWithRed:33.0 / 255.0 green:145.0 / 255.0 blue:251.0 / 255.0 alpha:1.0] forState:UIControlStateSelected];
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        titleBtn.tag = i;
        [self.titleBar addSubview:titleBtn];
        [self.buttonArray addObject:titleBtn];
    }
    // default select 1st
    UIButton *btn = self.buttonArray[0];
    btn.selected = YES;
    self.previousClickedtitleButton = btn;
}

- (void)setupDownLine {
    UIView *downLine = [[UIView alloc] init];
    [self.titleBar addSubview:downLine];
    self.downLine = downLine;
    UIButton *btn = self.buttonArray[0];
    downLine.backgroundColor = [btn titleColorForState:UIControlStateSelected];
}

- (void)updateFrame {
    self.titleBar.frame = CGRectMake(0, 0, self.width, self.height);
    CGFloat btnW = self.titleBar.width / self.buttonArray.count;
// modified for scroll enable
    if (self.buttonArray.count > 5) {
        btnW = self.titleBar.width / 5.5;
        ((UIScrollView *)self.titleBar).contentSize = CGSizeMake(btnW * self.buttonArray.count, 0);
    }
    CGFloat btnH = self.titleBar.height;
    for (int i = 0; i < self.buttonArray.count; i++) {
        UIButton *button = self.buttonArray[i];
        button.frame = CGRectMake(i * btnW, 0, btnW, btnH);
    }
    [self updateDownLineFrameToButton:self.buttonArray[0] withAnim:NO];
}

#pragma mark - event
- (void)titleBtnClick:(UIButton *)titleBtn {
    [self changeStatusToButton:titleBtn withAnim:YES];
// modified for scroll enable
    [self scrollToCenterOfButton:titleBtn];
    if ([self.delegate respondsToSelector:@selector(scrollTitleBar:didClickIndex:)]) {
        [self.delegate scrollTitleBar:self didClickIndex:titleBtn.tag];
    }
}

- (void)changeStatusToButton:(UIButton *)button withAnim:(BOOL)isAnim {
    self.previousClickedtitleButton.selected = NO;
    button.selected = YES;
    self.previousClickedtitleButton = button;
    [self updateDownLineFrameToButton:button withAnim:isAnim];
}

- (void)updateDownLineFrameToButton:(UIButton *)button withAnim:(BOOL)isAnim {
    self.downLine.height = 2;
    self.downLine.y = self.titleBar.height - 2;
    if (button.titleLabel.width == 0) { // 未展现出来时，titleLabel没有尺寸
        [button.titleLabel sizeToFit];
    }
    if (isAnim) {
        [UIView animateWithDuration:0.25 animations:^{
            self.downLine.width = button.titleLabel.width + 10;
            self.downLine.center = CGPointMake(button.center.x, self.downLine.center.y);
        }];
    } else {
        self.downLine.width = button.titleLabel.width + 10;
        self.downLine.center = CGPointMake(button.center.x, self.downLine.center.y);
    }
}

// modified for scroll enable
- (void)scrollToCenterOfButton:(UIButton *)button {
    CGFloat btnCenterX = button.center.x;
    CGFloat titleBarW = self.titleBar.frame.size.width;
    CGFloat contentW = ((UIScrollView *)self.titleBar).contentSize.width;
    CGFloat aimX = btnCenterX - titleBarW * 0.5;
    if (aimX < 0) {
        aimX = 0;
    }
    if (aimX > contentW - titleBarW) {
        aimX = contentW - titleBarW;
    }
    [((UIScrollView *)self.titleBar) setContentOffset:CGPointMake(aimX, 0) animated:YES];
}

@end
