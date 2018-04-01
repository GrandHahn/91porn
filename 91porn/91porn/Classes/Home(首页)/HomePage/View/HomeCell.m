//
//  HomeCell.m
//  91porn
//
//  Created by Hahn on 2018/3/22.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "HomeCell.h"
#import "Masonry.h"
#import "PornItem.h"
#import "UIImageView+WebCache.h"

@interface HomeCell ()

@property (nonatomic, weak) UIImageView *img;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *infoLabel;

@end

@implementation HomeCell

- (void)setItem:(PornItem *)item {
    _item = item;
    [self.img sd_setImageWithURL:[NSURL URLWithString:item.imgUrl] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    self.titleLabel.text = [NSString stringWithFormat:@"%@(时长:%@)", item.title, item.duration];
    self.infoLabel.text = item.info;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *img = [[UIImageView alloc] init];
    [self.contentView addSubview:img];
    self.img = img;
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@80);
        make.bottom.lessThanOrEqualTo(self.contentView.mas_bottom).offset(-10);
    }];
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.clipsToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(img.mas_right).offset(10);
        make.top.equalTo(img.mas_top);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    titleLabel.numberOfLines = 0;
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [self.contentView addSubview:infoLabel];
    self.infoLabel = infoLabel;
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.right.equalTo(self.titleLabel.mas_right);
        make.left.equalTo(self.titleLabel.mas_left);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont systemFontOfSize:13];
    infoLabel.textColor = [UIColor lightGrayColor];
}

@end
