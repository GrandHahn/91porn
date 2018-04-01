//
//  PictureController.m
//  91porn
//
//  Created by Hahn on 2018/3/26.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "PictureController.h"
#import "CTScrollBarView.h"
#import "PicturePageController.h"

@interface PictureController () <CTScrollBarViewDelegate>

@property (nonatomic, weak) CTScrollBarView *barView;

@end

@implementation PictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"图片";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildViewControllers];
    [self setupScrollBarView];
}

- (void)setupScrollBarView {
    CTScrollBarView *barView = [CTScrollBarView barViewWithFrame:CGRectZero andTitleArray:@[@"主页", @"最热", @"推荐", @"性感妹子", @"日本妹子", @"台湾妹子", @"清纯妹子"] andDelegate:self];
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
    NSArray *types = @[@"index", @"hot", @"best", @"xinggan", @"japan", @"taiwan", @"mm"];
    for (int i = 0; i < types.count; i++) {
        PicturePageController *vc = [[PicturePageController alloc] init];
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
