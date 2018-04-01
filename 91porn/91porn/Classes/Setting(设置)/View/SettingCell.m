//
//  SettingCell.m
//  91porn
//
//  Created by Hahn on 2018/3/25.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "SettingCell.h"
#import "Masonry.h"

@interface SettingCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *detailLabel;

@end

@implementation SettingCell

- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    NSString *title = dict[@"title"];
    NSString *detail = dict[@"detail"];
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo(self.contentView.mas_top);
        make.height.equalTo(self.contentView.mas_height).multipliedBy(0.5);
        make.right.equalTo(self.contentView.mas_right).offset(-50);
    }];
    
    UILabel *detailLabel = [[UILabel alloc] init];
    [self.contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_left);
        make.top.equalTo(titleLabel.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.right.equalTo(titleLabel.mas_right);
    }];
    detailLabel.textColor = [UIColor lightGrayColor];
}

@end
