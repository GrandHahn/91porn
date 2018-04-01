//
//  HomeController.m
//  91porn
//
//  Created by Hahn on 2018/3/24.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "HomeController.h"
#import "CTScrollBarView.h"
#import "HomePageController.h"

@interface HomeController () <CTScrollBarViewDelegate>

@property (nonatomic, weak) CTScrollBarView *barView;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"视频";
    [self setupChildViewControllers];
    [self setupScrollBarView];
}

- (void)setupScrollBarView {
    CTScrollBarView *barView = [CTScrollBarView barViewWithFrame:CGRectZero andTitleArray:@[@"主页", @"最近更新", @"当前最热", @"最近得分", @"10分钟上", @"本月讨论", @"本月收藏", @"收藏最多", @"最近加精", @"本月最热", @"上月最热", @"高清会员"] andDelegate:self];
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
    NSArray *categorys = @[@"index", @"recent",@"hot", @"rp", @"long", @"md", @"tf", @"mf", @"rf", @"top", @"top1", @"hd"];
    for (int i = 0; i < categorys.count; i++) {
        HomePageController *vc = [[HomePageController alloc] init];
        vc.type = categorys[i];
        [self addChildViewController:vc];
    }
}

#pragma mark - CTScrollBarViewDelegate
- (UIView *)scrollBarView:(CTScrollBarView *)barView viewAtIndex:(NSInteger)index {
    UIViewController *vc = self.childViewControllers[index];
    return vc.view;
}

@end
