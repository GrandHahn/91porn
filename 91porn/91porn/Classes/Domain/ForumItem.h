//
//  ForumItem.h
//  91porn
//
//  Created by Hahn on 2018/3/27.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ForumItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *authorPublishTime;
@property (nonatomic, strong) NSString *viewCount;
@property (nonatomic, strong) NSString *replyCount;
@property (nonatomic, strong) NSString *lastPostTime;
@property (nonatomic, strong) NSString *lastPostAuthor;
@property (nonatomic, strong) NSString *tidStr;

@end
