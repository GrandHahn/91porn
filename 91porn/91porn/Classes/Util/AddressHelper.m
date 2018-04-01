//
//  AddressHelper.m
//  91porn
//
//  Created by Hahn on 2018/3/23.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "AddressHelper.h"

NSString * VideoUrlWith(NSString *path) {
    NSString *domain = [AddressHelper getVideoAddress];
    return [NSString stringWithFormat:@"%@%@", domain, path];
}

NSString * ForumUrlWith(NSString *path) {
    NSString *domain = [AddressHelper getForumAddress];
    return [NSString stringWithFormat:@"%@%@", domain, path];
}

@implementation AddressHelper

+ (BOOL)isLegalHttpUrl:(NSString *)url {
    // 原表达式^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$
    // 正则表达式
    NSString *pattern = @"^https?://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$";
    // 正则表达式对象
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 匹配
    NSArray *resultArray = [regularExpression matchesInString:url options:NSMatchingReportProgress range:NSMakeRange(0, url.length)];
    if (resultArray.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)saveVideoAddress:(NSString *)address {
    BOOL isCurrent = [self isLegalHttpUrl:address];
    if (!isCurrent) {
        NSLog(@"error address");
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"videoAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveForumAddress:(NSString *)address {
    BOOL isCurrent = [self isLegalHttpUrl:address];
    if (!isCurrent) {
        NSLog(@"error address");
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"forumAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getVideoAddress {
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"videoAddress"];
    if (url == nil) url = @"";
    return url ? url : @"";
}

+ (NSString *)getForumAddress {
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"forumAddress"];
    if (url == nil) url = @"";
    return url;
}

+ (NSString *)getRandomIPAddress {
    return [NSString stringWithFormat:@"%d.%d.%d.%d", arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255)];
}

@end
