//
//  ForumPageOtherController.m
//  91porn
//
//  Created by Hahn on 2018/3/27.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ForumPageOtherController.h"
#import "ForumCell.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "ApiService.h"
#import "ForumItem.h"
#import "ForumContent.h"
#import "ForumContentController.h"
#import "SVProgressHUD.h"
#import "UITableView+FDTemplateLayoutCell.h"
static NSString * const ForumCellID = @"ForumCell";

@interface ForumPageOtherController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ForumItem *> *datas;
@property (nonatomic, assign) NSInteger page;

@end

@implementation ForumPageOtherController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupRefresh];
}

#pragma mark - data
- (void)loadData {
    [[ApiService shareInstance] requestForumOtherType:self.type page:1 success:^(NSMutableArray<ForumItem *> *datas) {
        self.datas = datas;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        if (self.datas.count <= 0) {
            if ([self.type isEqualToString:@"17"]
                || [self.type isEqualToString:@"4"]) {
                NSLog(@"该模块需要账号，暂不可使用");
                [SVProgressHUD showInfoWithStatus:@"该模块需要账号，暂不可使用"];
            }
        } else {
            self.page = 1;
            self.tableView.mj_footer.hidden = NO;
        }
    } fail:^(NSString *msg) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreData {
    [[ApiService shareInstance] requestForumOtherType:self.type page:self.page + 1 success:^(NSMutableArray<ForumItem *> *datas) {
        [self.datas addObjectsFromArray:datas];
        [self.tableView reloadData];
        self.page += 1;
        [self.tableView.mj_footer endRefreshing];
    } fail:^(NSString *msg) {
        [self.tableView.mj_footer endRefreshing];
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
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_footer setEndRefreshingCompletionBlock:^{
        
    }];
    
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

