//
//  CTPhotoBrowserController.h
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/22.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTPhotoBrowserAnimator.h"
@interface CTPhotoBrowserController : UIViewController <CTDismissDelegate>
/** 图片数组。可传入NSString类型的url或UIImage类型，也可混传。 */
@property (nonatomic, strong) NSArray *imageArray;
/** 弹出时展示第几张图片。默认0。 */
@property (nonatomic, assign) NSInteger indexOfImageWillShow;

@end
