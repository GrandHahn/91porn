//
//  TabBarController.m
//  91porn
//
//  Created by Hahn on 2018/3/23.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "TabBarController.h"
#import "NavigationController.h"
#import "HomeController.h"
#import "SettingController.h"
#import "PictureController.h"
#import "ForumController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    [self setUpAllChildVC];
    [self setUpAllTabBar];
}

- (void)setUpAllChildVC {
    HomeController *home = [[HomeController alloc] init];
    [self setUpOneChildVC:home];
    PictureController *picture = [[PictureController alloc] init];
    [self setUpOneChildVC:picture];
    ForumController *forum = [[ForumController alloc] init];
    [self setUpOneChildVC:forum];
    SettingController *setting = [[SettingController alloc] init];
    [self setUpOneChildVC:setting];
}

- (void)setUpOneChildVC:(UIViewController *)vc {
    NavigationController *navC = [[NavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:navC];
}

- (void)setUpAllTabBar {
    NSArray *arrayImageName = @[@"video", @"picture", @"forum", @"setting"];
    NSArray *arrayTitle = @[@"视频", @"图片", @"论坛", @"设置"];
    for (int i = 0; i < arrayImageName.count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"tabbar_%@", arrayImageName[i]];
        NSString *highImageName = [NSString stringWithFormat:@"tabbar_%@_HL", arrayImageName[i]];
        [self setUpOneTabBarWithIndex:i imageName:imageName highImageName:highImageName title:arrayTitle[i]];
    }
}

- (void)setUpOneTabBarWithIndex:(NSInteger)index imageName:(NSString *)imageName highImageName:(NSString *)highImageName title:(NSString *)title{
    NavigationController *navigationC = self.childViewControllers[index];
    // 图片
    navigationC.tabBarItem.image = [self originalImageWithImageName:imageName];
    navigationC.tabBarItem.selectedImage = [self originalImageWithImageName:highImageName];
    // 文字
    navigationC.tabBarItem.title = title;
    // 普通文字颜色
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:160 / 255.0 green:160 / 255.0 blue:160 / 255.0 alpha:1];
    [navigationC.tabBarItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    // 高亮文字颜色
    NSMutableDictionary *attributesSelected = [NSMutableDictionary dictionary];
    attributesSelected[NSForegroundColorAttributeName] = [UIColor colorWithRed:58.0 / 255.0 green:166.0 / 255.0 blue:234.0 / 255.0 alpha:1.0];
    [navigationC.tabBarItem setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];
}

// 返回原色图片
- (UIImage *)originalImageWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

@end
