//
//  ApiService.m
//  91porn
//
//  Created by Hahn on 2018/3/22.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ApiService.h"
#import "AFNetworking.h"
#import "ParseTool.h"
#import "PornItem.h"
#import "VideoResult.h"
#import "AddressHelper.h"
#import "MeiZiTuItem.h"

@implementation ApiService

static ApiService *apiService = nil;
+ (instancetype)shareInstance {
    @synchronized(self) {
        if (apiService == nil) {
            apiService = [[ApiService alloc] init];
        }
    }
    return apiService;
}

- (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;
    [req setHTTPShouldHandleCookies:NO];
    [req setValue:nil forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"zh-CN" forHTTPHeaderField:@"Accept-Language"];
    // [req setValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    // NSLog(@"%@", [req HTTPRequestHeaders]);
    
    AFHTTPResponseSerializer *resp = [AFHTTPResponseSerializer serializer];
    resp.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = resp;
    
    return manager;
}

- (void)requestIndex:(void (^)(NSMutableArray<PornItem *> *datas))success fail:(void (^)(NSString *msg))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    [manager POST:VideoUrlWith(@"/index.php") parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [NSString stringWithUTF8String:[responseObject bytes]];
        NSMutableArray<PornItem *> *array = [ParseTool parseIndex:res];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestVideo:(NSString *)viewkey success:(void (^)(VideoResult *data))success fail:(void (^)(NSString *msg))fail {
    AFHTTPSessionManager *manager = [self manager];
    manager.requestSerializer.timeoutInterval = 5;
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;
    NSString *randomIP = [AddressHelper getRandomIPAddress];
    [req setValue:randomIP forHTTPHeaderField:@"X-Forwarded-For"];
    [req setValue:VideoUrlWith(@"/index.php") forHTTPHeaderField:@"Referer"];
    
    NSDictionary *params = @{@"viewkey" : viewkey};
    
    [manager GET:VideoUrlWith(@"/view_video.php") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [NSString stringWithUTF8String:[responseObject bytes]];
        VideoResult *result = [ParseTool parseVideo:res];
        success(result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(@"failed");
    }];
}

- (void)requestRecentUpdatesPage:(NSInteger)page success:(void (^)(NSMutableArray<PornItem *> *datas))success fail:(void (^)(NSString *msg))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;
    //FIXME:该请求的返回的中文页面无法转化，待解决
    [req setValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:VideoUrlWith(@"/index.php") forHTTPHeaderField:@"Referer"];
    
    NSDictionary *params = @{
                             @"next" : @"watch",
                             @"page" : @(page)
                             };
    
    [manager GET:VideoUrlWith(@"/v.php") parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (res == nil) {
            res = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        }
        if (res == nil) {
            fail(@"网页转化错误");
            return;
        }
        NSMutableArray<PornItem *> *datas = [ParseTool parseRecentUpate:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestCategory:(NSString *)category page:(NSInteger)page success:(void (^)(NSMutableArray<PornItem *> *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;    [req setHTTPShouldHandleCookies:NO];
    [req setValue:nil forHTTPHeaderField:@"User-Agent"];
    [req setValue:VideoUrlWith(@"/index.php") forHTTPHeaderField:@"Referer"];
    //FIXME:该请求的返回的中文页面无法转化，待解决
    [req setValue:@"en" forHTTPHeaderField:@"Accept-Language"];
    
    NSArray *categorys = @[@"hot", @"rp", @"long", @"md", @"tf", @"mf", @"rf", @"top", @"top1", @"hd"];
    NSSet *set = [NSSet setWithArray:categorys];
    
    if (![category isKindOfClass:[NSString class]]
        || ![set containsObject:category]) {
        category = @"hot";
        NSLog(@"type error");
    }
    
    NSString *m = @"";
    if ([@"top1" isEqualToString:category]) {
        m = @"-1";
    }
    
    NSDictionary *params = @{
                             @"category" : category,
                             @"viewtype" : @"basic",
                             @"page" : @(page),
                             @"m" : m
                             };
    
    [manager GET:VideoUrlWith(@"/v.php") parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (res == nil) {
            res = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        }
        if (res == nil) {
            fail(@"网页转化错误");
            return;
        }
        NSMutableArray<PornItem *> *datas = [ParseTool parseRecentUpate:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestMeiZiTu:(NSString *)type page:(NSInteger)page success:(void (^)(NSMutableArray<MeiZiTuItem *> *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;
    [req setValue:@"http://www.mzitu.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"mei_zi_tu_domain_name" forHTTPHeaderField:@"Domain-Name"];
    
    NSString *path = nil;
    if (![type isKindOfClass:[NSString class]]
        || [type isEqualToString:@"index"]) {
        path = [NSString stringWithFormat:@"http://www.mzitu.com/page/%ld/", page];
    } else {
        path = [NSString stringWithFormat:@"http://www.mzitu.com/%@/page/%ld/", type, page];
    }
    
    [manager GET:path parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray<MeiZiTuItem *> *datas = [ParseTool parseMeiZiTu:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestMeiZiTuContent:(NSString *)Id success:(void (^)(NSMutableArray<NSString *> *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    AFHTTPRequestSerializer *req = manager.requestSerializer;
    [req setValue:@"http://www.mzitu.com/" forHTTPHeaderField:@"Referer"];
    [req setValue:@"mei_zi_tu_domain_name" forHTTPHeaderField:@"Domain-Name"];
    
    NSString *path = [NSString stringWithFormat:@"http://www.mzitu.com/%@", Id];
    
    [manager GET:path parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray<NSString *> *datas = [ParseTool parseMeiZiTuContent:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestForum:(void (^)(NSMutableArray<ForumItem *> *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
        
    [manager GET:ForumUrlWith(@"/index.php") parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray<ForumItem *> *datas = [ParseTool parseForum:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestForumContent:(NSString *)tid success:(void (^)(ForumContent *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
    manager.requestSerializer.timeoutInterval = 5;
    
    NSDictionary *param = @{@"tid" : tid};
    
    [manager GET:ForumUrlWith(@"/viewthread.php") parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        ForumContent *data = [ParseTool parseForumContent:res];
        success(data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

- (void)requestForumOtherType:(NSString *)type page:(NSInteger)page success:(void (^)(NSMutableArray<ForumItem *> *))success fail:(void (^)(NSString *))fail {
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *param = @{
                            @"fid" : type,
                            @"page" : @(page),
                            };
    
    [manager GET:ForumUrlWith(@"/forumdisplay.php") parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray<ForumItem *> *datas = [ParseTool parseForumOther:res];
        success(datas);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        fail(@"failed");
    }];
}

@end
