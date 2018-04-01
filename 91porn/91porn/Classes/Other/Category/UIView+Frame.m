//
//  UIView+Frame.m
//  20160331BuDeJie
//
//  Created by Hahn on 16/4/7.
//  Copyright © 2016年 Hahn. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)
- (void)setCenterX:(CGFloat)centerX {
    CGPoint tempCenter = self.center;
    tempCenter.x = centerX;
    self.center = tempCenter;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint tempCenter = self.center;
    tempCenter.y = centerY;
    self.center = tempCenter;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setHeight:(CGFloat)height {
    CGRect tempF = self.frame;
    tempF.size.height = height;
    self.frame = tempF;
}
- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setWidth:(CGFloat)width {
    CGRect tempF = self.frame;
    tempF.size.width = width;
    self.frame = tempF;
}
- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setY:(CGFloat)y {
    CGRect tempF = self.frame;
    tempF.origin.y = y;
    self.frame = tempF;
}
- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setX:(CGFloat)x {
    CGRect tempF = self.frame;
    tempF.origin.x = x;
    self.frame = tempF;
}
- (CGFloat)x {
    return self.frame.origin.x;
}
@end
