//
//  CTPhotoBrowserViewCell.m
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/22.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTPhotoBrowserViewCell.h"
#import "UIImageView+WebCache.h"

@interface CTPhotoBrowserViewCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation CTPhotoBrowserViewCell

- (void)setImage:(UIImage *)image {
    _image = image;
    
    // 循环使用换图片前要还原放大比例。否则旧的图放大过，新的图无法放大但却能缩小。
    [self.scrollView setZoomScale:1.0 animated:NO];
    
    // 还原offset
    self.scrollView.contentOffset = CGPointZero;
    
    self.imageView.image = image;
    
    CGRect calculateFrame = CGRectZero;
    if (image) {
        CGFloat x = 0;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * image.size.height / image.size.width;
        
        CGFloat y = 0;
        if (height > [UIScreen mainScreen].bounds.size.height) {
            // 长图
            y = 0;
            self.scrollView.contentSize = CGSizeMake(0, height);
        } else {
            // 非长图
            y = ([UIScreen mainScreen].bounds.size.height - height) * 0.5;
            self.scrollView.contentSize = CGSizeMake(0, 0);
        }
        
        calculateFrame = CGRectMake(x, y, width, height);
    }
    
    self.imageView.frame = calculateFrame;
}

- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
    
    // 循环使用换图片前要还原放大比例。否则旧的图放大过，新的图无法放大但却能缩小。
    [self.scrollView setZoomScale:1.0 animated:NO];
    
    // 还原offset
    self.scrollView.contentOffset = CGPointZero;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        CGRect calculateFrame = CGRectZero;
        if (image) {
            CGFloat x = 0;
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            CGFloat height = width * image.size.height / image.size.width;
            
            CGFloat y = 0;
            if (height > [UIScreen mainScreen].bounds.size.height) {
                // 长图
                y = 0;
                self.scrollView.contentSize = CGSizeMake(0, height);
            } else {
                // 非长图
                y = ([UIScreen mainScreen].bounds.size.height - height) * 0.5;
                self.scrollView.contentSize = CGSizeMake(0, 0);
            }
            
            calculateFrame = CGRectMake(x, y, width, height);
        }
        
        self.imageView.frame = calculateFrame;
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUIWithScrollView];
    }
    return self;
}

- (void)setupUI {
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
}

- (void)setupUIWithScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.scrollView = scrollView;
    [self.contentView addSubview:scrollView];
    scrollView.maximumZoomScale = 2.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView addSubview:imageView];
    self.imageView = imageView;
    
    // 单击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
    [scrollView addGestureRecognizer:singleTap];
    // 双击
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];
    
    // 无双击才响应单击
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

#pragma mark - 缩放

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    self.imageView.center = CGPointMake(xcenter, ycenter);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - event
- (void)singleClick:(UITapGestureRecognizer *)tap {
    
}

- (void)doubleClick:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
        
    } else {
        
        CGPoint center = [tap locationInView:self.scrollView];
        CGRect rect = CGRectZero;
        
        rect.size.width = self.scrollView.frame.size.width / self.scrollView.maximumZoomScale;
        rect.size.height = self.scrollView.frame.size.height / self.scrollView.maximumZoomScale;
        rect.origin.x = center.x - (rect.size.width / 2.0);
        rect.origin.y = center.y - (rect.size.height / 2.0);
        
        [self.scrollView zoomToRect:rect animated:YES];
    }
}

@end
