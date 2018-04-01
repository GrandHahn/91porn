//
//  ForumController.m
//  91porn
//
//  Created by Hahn on 2018/3/26.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ForumController.h"
#import "CTScrollBarView.h"
#import "ForumPageIndexController.h"
#import "ForumPageOtherController.h"

@interface ForumController () <CTScrollBarViewDelegate>

@property (nonatomic, weak) CTScrollBarView *barView;

@end

@implementation ForumController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"论坛";
    [self setupChildViewControllers];
    [self setupScrollBarView];
}

- (void)setupScrollBarView {
    CTScrollBarView *barView = [CTScrollBarView barViewWithFrame:CGRectZero andTitleArray:@[@"主页", @"自拍达人", @"原创申请", @"原创自拍", @"我爱我妻", @"兴趣分享", @"健康"] andDelegate:self];
    barView.lazyLoad = YES;
    [self.view addSubview:barView];
    self.barView = barView;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat navH = self.navigationController.navigationBar.bounds.size.height;
    CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat tabBarH = ((UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController).tabBar.frame.size.height;
    barView.frame = CGRectMake(0, 0, screenW, screenH - navH - statusH - tabBarH);
}

#pragma mark - childView
- (void)setupChildViewControllers {
    ForumPageIndexController *vc = [[ForumPageIndexController alloc] init];
    [self addChildViewController:vc];
    NSArray *types = @[@"17", @"19", @"4", @"21", @"33", @"34"];
    for (int i = 0; i < types.count; i++) {
        ForumPageOtherController *vc = [[ForumPageOtherController alloc] init];
        vc.type = types[i];
        [self addChildViewController:vc];
    }
}

#pragma mark - CTScrollBarViewDelegate
- (UIView *)scrollBarView:(CTScrollBarView *)barView viewAtIndex:(NSInteger)index {
    UIViewController *vc = self.childViewControllers[index];
    return vc.view;
}

@end
