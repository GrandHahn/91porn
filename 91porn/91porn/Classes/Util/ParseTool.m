//
//  ParseTool.m
//  91porn
//
//  Created by Hahn on 2018/3/22.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ParseTool.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement+PornExtension.h"
#import "PornItem.h"
#import "VideoResult.h"
#import "MeiZiTuItem.h"
#import "ForumItem.h"
#import "ForumContent.h"
#import "AddressHelper.h"

@implementation ParseTool

+ (NSMutableArray *)parseIndex:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    
    GDataXMLElement *body = [doc nodesForXPath:@"//*[@id='tab-featured']" error:&error].firstObject;
    NSArray *itms = [body nodesForXPath:@"p" error:&error];
    NSLog(@"index count:%zd", itms.count);
    
    NSMutableArray *tempArr = [NSMutableArray array];
    
    for (int i = 0; i < itms.count; i++) {
        GDataXMLElement *element = itms[i];
        
        NSString *title = ((GDataXMLElement *)[element nodesForXPath:@".//*[@class='title']" error:&error].firstObject).stringValue;
        
        NSString *imgUrl = [((GDataXMLElement *)[element nodesForXPath:@".//img" error:&error].firstObject) attributeForName:@"src"].stringValue;
        
        NSString *duration = ((GDataXMLElement *)[element nodesForXPath:@".//*[@class='duration']" error:&error].firstObject).stringValue;
        
        NSString *contentUrl = [((GDataXMLElement *)[element nodesForXPath:@"a" error:&error].firstObject) attributeForName:@"href"].stringValue;
        NSInteger index = [contentUrl rangeOfString:@"="].location + [contentUrl rangeOfString:@"="].length;
        NSString *viewKey = [contentUrl substringFromIndex:index];
        
        NSInteger start = [element.stringValue rangeOfString:@"添加时间"].location;
        NSString *info = @"";
        if (start < element.stringValue.length) {
            info = [element.stringValue substringFromIndex:start];
            info = [info stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info = [info stringByReplacingOccurrencesOfString:@" " withString:@""];
            info = [info stringByReplacingOccurrencesOfString:@"\xc2\xa0" withString:@""];
        }
        
        NSLog(@"------ %zd -------", i);
        NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n", title, imgUrl, duration, contentUrl, viewKey, info);
        
        PornItem *item = [[PornItem alloc] init];
        item.title = title;
        item.imgUrl = imgUrl;
        item.duration = duration;
        item.viewKey = viewKey;
        item.info = info;
        
        [tempArr addObject:item];
    }
    
    return tempArr;
}

+ (VideoResult *)parseVideo:(NSString *)html {
    if ([html containsString:@"你每天只可观看10个视频"]) {
        NSLog(@"已经超出观看上限了");
    }
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    
//    NSString *videoUrl = [((GDataXMLElement *)[[doc nodesForXPath:@"//video" error:&error].firstObject nodesForXPath:@".//source" error:&error].firstObject) attributeForName:@"src"].stringValue;
    NSString *videoUrl = [self parseVideoUrl:html];
    
    NSInteger startIndex = [videoUrl rangeOfString:@"/" options:NSBackwardsSearch].location;
    NSInteger endIndex = [videoUrl rangeOfString:@".mp4"].location;
    NSString *videoId = [videoUrl substringWithRange:NSMakeRange(startIndex + 1, endIndex - startIndex - 1)];
    
    NSString *ownerUrl = [[doc nodesForXPath:@"//a[contains(@href,'UID')]" error:&error].firstObject attributeForName:@"href"].stringValue;
    NSString *ownerId = [ownerUrl substringFromIndex:[ownerUrl rangeOfString:@"="].location + 1];
    
    NSString *ownerName = ((GDataXMLElement *)[doc nodesForXPath:@"//a[contains(@href,'UID')]" error:&error].firstObject).stringValue;
    
    NSString *thumImg = [((GDataXMLElement *)[doc nodesForXPath:@"//*[@id='vid']" error:&error].firstObject) attributeForName:@"poster"].stringValue;
    
    NSString *videoName = ((GDataXMLElement *)[doc nodesForXPath:@"//*[@id='viewvideo-title']" error:&error].firstObject).stringValue;
    videoName = [videoName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    videoName = [videoName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n", videoUrl, videoId, ownerUrl, ownerId, ownerName, thumImg, videoName);
    
    VideoResult *result = [[VideoResult alloc] init];
    result.videoUrl = videoUrl;
    result.videoId = videoId;
    result.videoUrl = videoUrl;
    result.ownerUrl = ownerUrl;
    result.ownerId = ownerId;
    result.ownerName = ownerName;
    result.thumImg = thumImg;
    result.videoName = videoName;
    
    return result;
}

+ (NSString *)parseVideoUrl:(NSString *)html {
    // 1.取出加密字段1和加密字段2
    // 原表达式document\.write\(strencode\("(.+)","(.+)",".+"\)\);
    NSString *pattern = @"document\\.write\\(strencode\\(\"(.+)\",\"(.+)\",\".+\"\\)\\);";
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regularExpression matchesInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)].firstObject;
    if (!result || [result numberOfRanges] < 3) return @"";
    NSString *str1 = [html substringWithRange:[result rangeAtIndex:1]];
    NSString *str2 = [html substringWithRange:[result rangeAtIndex:2]];
    // 2.解密出source元素
    NSData *data1 = [[NSData alloc] initWithBase64EncodedString:str1 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *data2 = [str2 dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *dataM = [NSMutableData data];
    for (int i = 0; i < data1.length; i++) {
        int k = i % data2.length;
        Byte bytes1;
        [data1 getBytes:&bytes1 range:NSMakeRange(i, 1)];
        Byte bytes2;
        [data2 getBytes:&bytes2 range:NSMakeRange(k, 1)];
        Byte byte = bytes1 ^ bytes2;
        [dataM appendBytes:&byte length:1];
    }
    NSData *sourceData = [[NSData alloc] initWithBase64EncodedData:dataM options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *source = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
    // 3.取出地址
    GDataXMLElement *sourceElement = [[GDataXMLElement alloc] initWithHTMLString:source error:nil];
    NSString *videoUrl = [[sourceElement nodesForXPath:@"//source" error:nil].firstObject attributeForName:@"src"].stringValue;
    return videoUrl;
}

+ (NSMutableArray *)parseRecentUpate:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    GDataXMLElement *body = [doc nodesForXPath:@"//*[@id='fullside']" error:&error].firstObject;
    NSArray *listchannels = [body nodesForXPath:@".//*[@class='listchannel']" error:&error];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < listchannels.count; i++) {
        GDataXMLElement *element = listchannels[i];
        NSString *contentUrl = [((GDataXMLElement *)[element nodesForXPath:@".//a" error:&error].firstObject) attributeForName:@"href"].stringValue;
        contentUrl = [contentUrl substringToIndex:[contentUrl rangeOfString:@"&"].location];
        NSString *viewKey = [contentUrl substringFromIndex:[contentUrl rangeOfString:@"="].location + 1];
        
        NSString *imgUrl = [((GDataXMLElement *)[[element nodesForXPath:@".//a" error:&error].firstObject nodesForXPath:@".//img" error:&error].firstObject) attributeForName:@"src"].stringValue;
        
        NSString *title = [((GDataXMLElement *)[[element nodesForXPath:@".//a" error:&error].firstObject nodesForXPath:@".//img" error:&error].firstObject) attributeForName:@"title"].stringValue;
        
        NSString *allInfo = element.stringValue;
        NSInteger sindex = [allInfo rangeOfString:@"时长"].location;
        NSString *duration = @"";
        if (sindex < allInfo.length) {
            duration = [allInfo substringWithRange:NSMakeRange(sindex + 3, 5)];
        }
        if ([duration isEqualToString:@""]) { // 取英文版
            sindex = [allInfo rangeOfString:@"Runtime"].location;
            if (sindex < allInfo.length) {
                duration = [allInfo substringWithRange:NSMakeRange(sindex + 8, 5)];
            }
        }
        
        NSInteger start = [allInfo rangeOfString:@"添加时间"].location;
        NSString *info = @"";
        if (start < allInfo.length) {
            info = [allInfo substringFromIndex:start];
        }
        if ([info isEqualToString:@""]) { // 取英文版
            start = [allInfo rangeOfString:@"Added"].location;
            if (start < allInfo.length) {
                info = [allInfo substringFromIndex:start];
            }
        }
//        info = [info stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        info = [info stringByReplacingOccurrencesOfString:@" " withString:@""];
//        info = [info stringByReplacingOccurrencesOfString:@"\xc2\xa0" withString:@""];
//        info = [info stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        info = [self changeMutiSpaceToOneSpace:info];
        
        NSLog(@"!!!------- %d ------", i);
        allInfo = @"";
        NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n", contentUrl, viewKey, imgUrl, title, allInfo, duration, info);
        
        PornItem *item = [[PornItem alloc] init];
        item.viewKey = viewKey;
        item.imgUrl = imgUrl;
        item.title = title;
        item.duration = duration;
        item.info = info;
        [tempArr addObject:item];
    }
    return tempArr;
}

+ (NSMutableArray *)parseMeiZiTu:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    GDataXMLElement *ulPins = doc.getElementById(@"pins");
    NSArray *lis = ulPins.select(@"li");
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < lis.count; i++) {
        GDataXMLElement *li = lis[i];
//        NSString *contentUrl = li.selectFirst(@"a").attribute(@"href");
        GDataXMLElement *aOfLi = li.selectFirst(@"a");
        if (!aOfLi) continue;
        NSString *contentUrl = aOfLi.attribute(@"href");
        NSInteger index = [contentUrl rangeOfString:@"/" options:NSBackwardsSearch].location;
        NSString *idStr = @"";
        if (index < contentUrl.length) {
            idStr = [contentUrl substringFromIndex:index + 1];
        }
        GDataXMLElement *imageElement = li.selectFirst(@"img");
        NSString *name = imageElement.attribute(@"alt");
        NSString *thumbUrl = imageElement.attribute(@"data-original");
        NSString *height = imageElement.attribute(@"height");
        NSString *width = imageElement.attribute(@"width");
        NSString *date = li.getElementByClassFirst(@"time").stringValue;
        NSString *viewCount = li.getElementByClassFirst(@"view").stringValue;
        
        NSLog(@"Mzitu------%d-------", i);
        NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n", contentUrl, idStr, name, thumbUrl, height, width, date, viewCount);
        
        MeiZiTuItem *item = [[MeiZiTuItem alloc] init];
        item.Id = idStr;
        item.name = name;
        item.thumbUrl = thumbUrl;
        item.height = height;
        item.width = width;
        item.date = date;
        item.viewCount = viewCount;
        
        [tempArr addObject:item];
    }
    return tempArr;
}

+ (NSMutableArray *)parseMeiZiTuContent:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    GDataXMLElement *pageElement = doc.getElementByClassFirst(@"pagenavi");
    NSArray<GDataXMLElement *> *aElements = pageElement.select(@"a");
    NSInteger totalPage = 1;
    if (aElements.count > 3) {
        NSString *pageStr = aElements[aElements.count - 2].stringValue;
        totalPage = pageStr.integerValue;
    }
    NSMutableArray *imageUrlList = [NSMutableArray array];
    NSString *imageUrl = doc.getElementByClassFirst(@"main-image").selectFirst(@"img").attribute(@"src");
    if (totalPage <= 1) {
        [imageUrlList addObject:imageUrl];
    }
    for (int i = 1; i < totalPage + 1; i++) {
        NSString *picFormat = [NSString stringWithFormat:@"%02d.", i];
        NSString *img = [imageUrl stringByReplacingOccurrencesOfString:@"01." withString:picFormat];
        [imageUrlList addObject:img];
    }
    NSLog(@"%@", imageUrlList);
    return imageUrlList;
}

+ (NSMutableArray *)parseForum:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    NSArray<GDataXMLElement *> *tds = [doc nodesForXPath:@"//*[@background='images/listbg.gif']" error:&error];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < tds.count; i++) {
        GDataXMLElement *td = tds[i];
        NSArray *elements = td.select(@"a");
        NSString *aTitle = td.selectFirst(@"a").attribute(@"title");
        if ([aTitle containsString:@"最新精华"]) {
            NSLog(@"***** 最新精华 ******");
        } else if ([aTitle containsString:@"最新回复"]) {
            NSLog(@"***** 最新回复 ******");
        } else { // 本周热门
            NSLog(@"***** 本周热门 ******");
        }
        for (int i = 0; i < elements.count; i++) {
            GDataXMLElement *element = elements[i];
            NSString *allInfo = [element.attribute(@"title") stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSInteger titleIndex = [allInfo rangeOfString:@"主题标题:"].location;
            NSInteger authorIndex = [allInfo rangeOfString:@"主题作者:"].location;
            NSInteger authorPublishTimeIndex = [allInfo rangeOfString:@"发表时间:"].location;
            NSInteger viewCountIndex = [allInfo rangeOfString:@"浏览次数:"].location;
            NSInteger replyCountIndex = [allInfo rangeOfString:@"回复次数:"].location;
            NSInteger lastPostTimeIndex = [allInfo rangeOfString:@"最后回复:"].location;
            NSInteger lastPostAuthorIndex = [allInfo rangeOfString:@"最后发表:"].location;
            
            NSString *title = [allInfo substringWithRange:NSMakeRange(titleIndex + 5, authorIndex - titleIndex - 5)];
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *author = [allInfo substringWithRange:NSMakeRange(authorIndex + 5, authorPublishTimeIndex - authorIndex - 5)];
            NSString *authorPublishTime = [allInfo substringWithRange:NSMakeRange(authorPublishTimeIndex + 5, viewCountIndex - authorPublishTimeIndex - 5)];
            NSString *viewCount = [allInfo substringWithRange:NSMakeRange(viewCountIndex + 5, replyCountIndex - viewCountIndex - 5)];
            NSString *replyCount = [allInfo substringWithRange:NSMakeRange(replyCountIndex + 5, lastPostTimeIndex - replyCountIndex - 5)];
            NSString *lastPostTime = [allInfo substringWithRange:NSMakeRange(lastPostTimeIndex + 5, lastPostAuthorIndex - lastPostTimeIndex - 5)];
            NSString *lastPostAuthor = [allInfo substringWithRange:NSMakeRange(lastPostAuthorIndex + 5, allInfo.length - lastPostAuthorIndex - 5)];
            
            NSString *contentUrl = element.attribute(@"href");
            NSInteger startIndex = [contentUrl rangeOfString:@"tid="].location;
            NSString *tidStr = [contentUrl substringFromIndex:startIndex + 4];
            
            NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n", title, author, authorPublishTime, viewCount, replyCount, lastPostTime, lastPostAuthor, contentUrl, tidStr);
            
            ForumItem *item = [[ForumItem alloc] init];
            item.title = title;
            item.author = author;
            item.authorPublishTime = authorPublishTime;
            item.viewCount = viewCount;
            item.replyCount = replyCount;
            item.lastPostTime = lastPostTime;
            item.lastPostAuthor = lastPostAuthor;
            item.tidStr = tidStr;
            [tempArr addObject:item];
        }
    }
    return tempArr;
}

+ (ForumContent *)parseForumContent:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    GDataXMLElement *content = doc.getElementByClassFirst(@"t_msgfontfix");
    if (content == nil) {
        NSLog(@"failed");
        ForumContent *item = [[ForumContent alloc] init];
        item.content = @"failed parse";
        return item;
    }
    
    NSArray *attachPopups = doc.getElementByClass(@"imgtitle");
    for (int i = 0; i < attachPopups.count; i++) {
        GDataXMLElement *element = attachPopups[i];
        NSArray *children = element.children;
        for (int i = 0; i < children.count; i++) {
            [element removeChild:children[i]];
        }
    }
    
    NSArray *attach_popups = content.getElementByClass(@"attach_popup");
    for (int i = 0; i < attach_popups.count; i++) {
        GDataXMLElement *attach_popup = attach_popups[i];
        attach_popup.attributeMake(@"style", @"display: true");
    }
    
    NSArray *imagesElements = content.select(@"img");
    NSMutableArray *stringList = [NSMutableArray array];
    for (int i = 0; i < imagesElements.count; i++) {
        GDataXMLElement *element = imagesElements[i];
        NSString *imgUrl = element.attribute(@"src");
        if ([imgUrl isKindOfClass:[NSString class]]
            && ![imgUrl isEqualToString:@""]
            && [imgUrl containsString:@".jpg"]
            && ![imgUrl containsString:@"http"]) {
            imgUrl = [NSString stringWithFormat:ForumUrlWith(@"/%@"), imgUrl];
            element.attributeMake(@"src", imgUrl);
            [stringList addObject:imgUrl];
        } else if ([element.attribute(@"file") isKindOfClass:[NSString class]]
                   && ![element.attribute(@"file") isEqualToString:@""]) {
            imgUrl = element.attribute(@"file");
            imgUrl = [NSString stringWithFormat:ForumUrlWith(@"/%@"), imgUrl];
            element.attributeMake(@"src", imgUrl);
            [stringList addObject:imgUrl];
        }
        element.attributeMake(@"width", @"100%");
        element.attributeMake(@"height", @"auto");
    }
    NSLog(@"parseForumContent:%@", content);
    NSLog(@"parseForumContent:%@", stringList);
    
    ForumContent *item = [[ForumContent alloc] init];
    item.content = content.XMLString;
    item.imageList = stringList;
    return item;
}

+ (NSMutableArray *)parseForumOther:(NSString *)html {
    NSError *error = nil;
    GDataXMLElement *doc = [[GDataXMLElement alloc] initWithHTMLString:html error:&error];
    GDataXMLElement *table = doc.getElementByClassFirst(@"datatable");
    if (!table) return [NSMutableArray array];
    NSArray *tbodys = table.select(@"tbody");
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < tbodys.count; i++) {
        ForumItem *item = [[ForumItem alloc] init];
        GDataXMLElement *tbody = tbodys[i];
        GDataXMLElement *th = tbody.selectFirst(@"th");
        if ([th.stringValue containsString:@"版块主题"]) {
            continue;
        }
        NSString *title = th.selectFirst(@"a").stringValue;
        title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *contentUrl = th.selectFirst(@"a").attribute(@"href");
        NSInteger startIndex = [contentUrl rangeOfString:@"tid="].location;
        NSInteger endIndex = [contentUrl rangeOfString:@"&"].location;
        if (startIndex >= contentUrl.length
            || endIndex >= contentUrl.length) {
            continue;
        }
        NSString *tidStr = [contentUrl substringWithRange:NSMakeRange(startIndex + 4, endIndex - (startIndex + 4))];
        
        NSLog(@"------%d-----", i);
        NSLog(@"%@\n%@\n%@\n", title, contentUrl, tidStr);
        item.title = title;
        item.tidStr = tidStr;
        
        NSArray *tds = tbody.select(@"td");
        for (int j = 0; j < tds.count; j++) {
            GDataXMLElement *td = tds[j];
            NSString *className = td.attribute(@"class");
            if ([@"author" isEqualToString:className]) {
                NSString *author = td.selectFirst(@"a").stringValue;
                NSString *authorPublishTime = td.selectFirst(@"em").stringValue;
                NSLog(@"%@\n%@\n", author, authorPublishTime);
                item.author = author;
                item.authorPublishTime = authorPublishTime;
            }
            if ([@"nums" isEqualToString:className]) {
                NSString *replyCount = td.selectFirst(@"strong").stringValue;
                NSString *viewCount = td.selectFirst(@"em").stringValue;
                NSLog(@"%@\n%@\n", replyCount, viewCount);
                item.replyCount = replyCount;
                item.viewCount = viewCount;
            }
            if ([@"lastpost" isEqualToString:className]) {
                NSString *lastPostAuthor = td.selectFirst(@"a").stringValue;
                NSString *lastPostTime = td.selectFirst(@"em").stringValue;
                NSLog(@"%@\n%@\n", lastPostAuthor, lastPostTime);
                item.lastPostAuthor = lastPostAuthor;
                item.lastPostTime = lastPostTime;
            }
        }
        [tempArr addObject:item];
    }
    return tempArr;
}

+ (NSString *)changeMutiSpaceToOneSpace:(NSString *)str {
    // 原表达式\s{2,}
    // 正则表达式
    NSString *pattern = @"\\s{2,}";
    // 正则表达式对象
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 匹配
    NSArray *resultArray = [regularExpression matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    for (int i = (int)resultArray.count - 1; i >= 0; i--) {
        NSTextCheckingResult *result = resultArray[i];
        NSRange range = result.range;
        str = [str stringByReplacingCharactersInRange:range withString:@" "];
    }
    return str;
}

@end
