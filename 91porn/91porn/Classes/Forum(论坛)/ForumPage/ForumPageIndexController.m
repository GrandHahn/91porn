//
//  ForumPageIndexController.m
//  91porn
//
//  Created by Hahn on 2018/3/27.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ForumPageIndexController.h"
#import "ForumCell.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "ApiService.h"
#import "ForumItem.h"
#import "ForumContent.h"
#import "ForumContentController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SVProgressHUD.h"
static NSString * const ForumCellID = @"ForumCell";

@interface ForumPageIndexController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ForumItem *> *datas;

@end

@implementation ForumPageIndexController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupRefresh];
}

#pragma mark - data
- (void)loadData {
    [[ApiService shareInstance] requestForum:^(NSMutableArray<ForumItem *> *datas) {
        self.datas = datas;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } fail:^(NSString *msg) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - UI
- (void)setupUI {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    tableView.frame = CGRectMake(0, 0, sw, sh);
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[ForumCell class] forCellReuseIdentifier:ForumCellID];
}

- (void)setupRefresh {
    __weak typeof(self) weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    [self.tableView.mj_header setEndRefreshingCompletionBlock:^{
        
    }];
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:ForumCellID configuration:^(id cell) {
        [self configureCell:cell indexPath:indexPath];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:ForumCellID];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)configureCell:(ForumCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.item = self.datas[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ForumItem *item = self.datas[indexPath.row];
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在加载:%@", item.title]];
    [[ApiService shareInstance] requestForumContent:item.tidStr success:^(ForumContent *data) {
        ForumContentController *vc = [[ForumContentController alloc] init];
        vc.item = data;
        [SVProgressHUD dismiss];
        [self.navigationController pushViewController:vc animated:YES];
    } fail:^(NSString *msg) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"加载失败:%@", item.title]];
    }];
}

@end
