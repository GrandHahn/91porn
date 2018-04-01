//
//  AddressHelper.h
//  91porn
//
//  Created by Hahn on 2018/3/23.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * VideoUrlWith(NSString *path);
NSString * ForumUrlWith(NSString *path);

@interface AddressHelper : NSObject

+ (BOOL)isLegalHttpUrl:(NSString *)url;
+ (void)saveVideoAddress:(NSString *)address;
+ (void)saveForumAddress:(NSString *)address;

+ (NSString *)getVideoAddress;
+ (NSString *)getForumAddress;
+ (NSString *)getRandomIPAddress;

@end
