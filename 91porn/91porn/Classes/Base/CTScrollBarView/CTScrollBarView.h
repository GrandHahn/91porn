//
//  CTScrollBarView.h
//  testForTitleBarScroll
//
//  Created by Hahn on 2017/12/27.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CTScrollBarView;

@protocol CTScrollBarViewDelegate <NSObject>
- (UIView *)scrollBarView:(CTScrollBarView *)barView viewAtIndex:(NSInteger)index;
@end

@interface CTScrollBarView : UIView
@property (nonatomic, weak) id<CTScrollBarViewDelegate> delegate;
+ (instancetype)barViewWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andDelegate:(id<CTScrollBarViewDelegate>)delegate;
/** default NO */
@property (nonatomic, assign) BOOL lazyLoad;
@end
