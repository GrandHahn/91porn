//
//  ForumCell.m
//  91porn
//
//  Created by Hahn on 2018/3/27.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ForumCell.h"
#import "ForumItem.h"
#import "Masonry.h"

@interface ForumCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *authorLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *viewCountLabel;

@end

@implementation ForumCell

- (void)setItem:(ForumItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
    self.authorLabel.text = item.author;
    self.timeLabel.text = item.authorPublishTime;
    self.viewCountLabel.text = [NSString stringWithFormat:@"浏览%@", item.viewCount];
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
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    UILabel *authorLabel = [[UILabel alloc] init];
    [self.contentView addSubview:authorLabel];
    self.authorLabel = authorLabel;
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.right.equalTo(self.titleLabel.mas_right);
    }];
    authorLabel.numberOfLines = 1;
    authorLabel.font = [UIFont systemFontOfSize:13];
    authorLabel.textColor = [UIColor lightGrayColor];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.authorLabel.mas_bottom);
        make.right.equalTo(self.authorLabel.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    timeLabel.numberOfLines = 1;
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.textColor = [UIColor lightGrayColor];
    
    UILabel *viewCountLabel = [[UILabel alloc] init];
    [self.contentView addSubview:viewCountLabel];
    self.viewCountLabel = viewCountLabel;
    [viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.timeLabel.mas_bottom);
        make.left.equalTo(self.titleLabel.mas_left);
    }];
    viewCountLabel.numberOfLines = 0;
    viewCountLabel.font = [UIFont systemFontOfSize:13];
    viewCountLabel.textColor = [UIColor lightGrayColor];
}

@end
