//
//  PicturePageController.m
//  91porn
//
//  Created by Hahn on 2018/3/26.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "PicturePageController.h"
#import "Masonry.h"
#import "PictureCell.h"
#import "MJRefresh.h"
#import "ApiService.h"
#import "MeiZiTuItem.h"
#import "CTPhotoBrowserController.h"
static NSString * const PictureCellID = @"PictureCell";

@interface PicturePageController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger page;

@end

@implementation PicturePageController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupRefresh];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemW = screenW * 0.5 - 1;
    CGFloat itemH = itemW / 236.0 * 354.0;
    self.layout.itemSize = CGSizeMake(itemW, itemH);
    self.layout.minimumLineSpacing = 1;
    self.layout.minimumInteritemSpacing = 0;
}

#pragma mark - data
- (void)loadData {
    [[ApiService shareInstance] requestMeiZiTu:self.type page:1 success:^(NSMutableArray<MeiZiTuItem *> *datas) {
        self.datas = datas;
        self.page = 1;
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        self.collectionView.mj_footer.hidden = NO;
    } fail:^(NSString *msg) {
        [self.collectionView.mj_header endRefreshing];
    }];
}

- (void)loadMoreData {
    [[ApiService shareInstance] requestMeiZiTu:self.type page:self.page+1 success:^(NSMutableArray<MeiZiTuItem *> *datas) {
        [self.datas addObjectsFromArray:datas];
        self.page += 1;
        [self.collectionView reloadData];
        [self.collectionView.mj_footer endRefreshing];
    } fail:^(NSString *msg) {
        [self.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark - UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    self.layout = layout;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[PictureCell class] forCellWithReuseIdentifier:PictureCellID];
    collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)setupRefresh {
    __weak typeof(self) weakSelf = self;
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    [self.collectionView.mj_header setEndRefreshingCompletionBlock:^{
        
    }];
    ((MJRefreshNormalHeader *)self.collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.collectionView.mj_footer.hidden = YES;
    [self.collectionView.mj_footer setEndRefreshingCompletionBlock:^{
        
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PictureCellID forIndexPath:indexPath];
    cell.item = self.datas[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MeiZiTuItem *item = self.datas[indexPath.item];
    [[ApiService shareInstance] requestMeiZiTuContent:item.Id success:^(NSMutableArray<NSString *> *datas) {
        CTPhotoBrowserController *photoVC = [[CTPhotoBrowserController alloc] init];
        photoVC.imageArray = datas;
        [self presentViewController:photoVC animated:YES completion:nil];
    } fail:^(NSString *msg) {
        
    }];
}

@end
