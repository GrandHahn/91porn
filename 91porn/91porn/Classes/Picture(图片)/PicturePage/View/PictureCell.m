//
//  PictureCell.m
//  91porn
//
//  Created by Hahn on 2018/3/26.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "PictureCell.h"
#import "MeiZiTuItem.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface PictureCell ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation PictureCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
}

- (void)setItem:(MeiZiTuItem *)item {
    _item = item;
    [[SDWebImageManager sharedManager].imageDownloader setValue:@"http://www.mzitu.com/" forHTTPHeaderField:@"Referer"];
    [[SDWebImageManager sharedManager].imageDownloader setValue:@"mei_zi_tu_domain_name" forHTTPHeaderField:@"Domain-Name"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.thumbUrl] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
}

@end
