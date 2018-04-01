//
//  SettingController.m
//  91porn
//
//  Created by Hahn on 2018/3/25.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "SettingController.h"
#import "Masonry.h"
#import "SettingCell.h"
#import "AddressHelper.h"
#import "SVProgressHUD.h"
static NSString * const SettingCellID = @"SettingCell";

@interface SettingController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation SettingController

#pragma mark - data
- (void)setupData {
    NSArray *datas = @[
                   @[
                       @{@"title" : @"视频地址", @"detail" : [AddressHelper getVideoAddress]},
                       @{@"title" : @"论坛地址", @"detail" : [AddressHelper getForumAddress]},
                     ],
                   @[
                     @{@"title" : @"浏览历史", @"detail" : @"暂不可用"},
                     ],
                   ];
    self.datas = datas.mutableCopy;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
}

#pragma mark - UI
- (void)setupUI {
    self.navigationItem.title = @"设置";
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[SettingCell class] forCellReuseIdentifier:SettingCellID];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.datas[section];
    return sectionArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellID];
    NSArray *sectionArray = self.datas[indexPath.section];
    NSDictionary *dict = sectionArray[indexPath.row];
    cell.dict = dict;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            [self settingVideoUrl];
        } else if (row == 1) {
            [self settingForumUrl];
        }
    }
}

- (void)settingVideoUrl {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"视频地址" message:@"例子:https://www.baidu.com" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *address = alertVC.textFields.firstObject.text;
        NSLog(@"%@", address);
        if (![AddressHelper isLegalHttpUrl:address]) {
            [SVProgressHUD showInfoWithStatus:@"不规范的地址"];
        }
        [AddressHelper saveVideoAddress:address];
        [self setupData];
        [self.tableView reloadData];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [AddressHelper getVideoAddress];
    }];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

- (void)settingForumUrl {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"论坛地址" message:@"例子:https://www.baidu.com" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *address = alertVC.textFields.firstObject.text;
        NSLog(@"%@", address);
        if (![AddressHelper isLegalHttpUrl:address]) {
            [SVProgressHUD showInfoWithStatus:@"不规范的地址"];
        }
        [AddressHelper saveForumAddress:address];
        [self setupData];
        [self.tableView reloadData];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [AddressHelper getForumAddress];
    }];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

@end
