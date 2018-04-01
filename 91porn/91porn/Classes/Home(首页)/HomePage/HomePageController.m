//
//  HomePageController.m
//  91porn
//
//  Created by Hahn on 2018/3/22.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "HomePageController.h"
#import "Masonry.h"
#import "HomeCell.h"
#import "ApiService.h"
#import "SVProgressHUD.h"
#import "PornItem.h"
#import "VideoResult.h"
#import <AVKit/AVKit.h>
#import "MJRefresh.h"
#import "UITableView+FDTemplateLayoutCell.h"
static NSString * const HomeCellID = @"HomeCell";

@interface HomePageController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger page;

@end

@implementation HomePageController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupRefresh];
}

#pragma mark - datas
- (void)loadData {
    if ([self.type isEqualToString:@"index"]) {
        [[ApiService shareInstance] requestIndex:^(NSMutableArray<PornItem *> *datas) {
            self.datas = datas;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        } fail:^(NSString *msg) {
            [self.tableView.mj_header endRefreshing];
        }];
    } else if ([self.type isEqualToString:@"watch"]
               || [self.type isEqualToString:@"recent"]) {
        [[ApiService shareInstance] requestRecentUpdatesPage:1 success:^(NSMutableArray<PornItem *> *datas) {
            self.datas = datas;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            self.page = 1;
            self.tableView.mj_footer.hidden = NO;
        } fail:^(NSString *msg) {
            [self.tableView.mj_header endRefreshing];
        }];
    } else {
        [[ApiService shareInstance] requestCategory:self.type page:1 success:^(NSMutableArray<PornItem *> *datas) {
            self.datas = datas;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            self.page = 1;
            self.tableView.mj_footer.hidden = NO;
        } fail:^(NSString *msg) {
            [self.tableView.mj_header endRefreshing];
        }];
    }
}

- (void)loadMoreData {
    if ([self.type isEqualToString:@"index"]) {
        // index类型只有一页
    } else if ([self.type isEqualToString:@"watch"]
               || [self.type isEqualToString:@"recent"]) {
        [[ApiService shareInstance] requestRecentUpdatesPage:self.page+1 success:^(NSMutableArray<PornItem *> *datas) {
            [self.datas addObjectsFromArray:datas];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            self.page += 1;
        } fail:^(NSString *msg) {
            [self.tableView.mj_footer endRefreshing];
        }];
    } else {
        [[ApiService shareInstance] requestCategory:self.type page:self.page+1 success:^(NSMutableArray<PornItem *> *datas) {
            [self.datas addObjectsFromArray:datas];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            self.page += 1;
        } fail:^(NSString *msg) {
            [self.tableView.mj_footer endRefreshing];
        }];
    }
}

- (void)loadVideoData:(NSString *)viewKey withTitle:(NSString *)title {
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在加载:%@", title]];
    [[ApiService shareInstance] requestVideo:viewKey success:^(VideoResult *data) {
        NSString *url = data.videoUrl;
        [SVProgressHUD dismiss];
        AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
        playerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
        [self presentViewController:playerVC animated:YES completion:nil];
    } fail:^(NSString *msg) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"加载失败:%@", title]];
    }];
}

#pragma mark - UI
- (void)setupRefresh {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    [self.tableView.mj_header setEndRefreshingCompletionBlock:^{
        
    }];
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
    // index类型只有一页
    if (![self.type isEqualToString:@"index"]) {
        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadMoreData];
        }];
        
        self.tableView.mj_footer.hidden = YES;
        [self.tableView.mj_footer setEndRefreshingCompletionBlock:^{
            
        }];
    }
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[HomeCell class] forCellReuseIdentifier:HomeCellID];
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:HomeCellID configuration:^(id cell) {
        [self configureCell:cell indexPath:indexPath];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCellID];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureCell:(HomeCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.item = self.datas[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PornItem *item = self.datas[indexPath.row];
    NSString *viewKey = item.viewKey;
    [self loadVideoData:viewKey withTitle:item.title];
}

@end
