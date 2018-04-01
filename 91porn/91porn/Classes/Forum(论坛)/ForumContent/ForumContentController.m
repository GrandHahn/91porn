//
//  ForumContentController.m
//  91porn
//
//  Created by Hahn on 2018/3/27.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "ForumContentController.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"

@interface ForumContentController () <WKNavigationDelegate>

@end

@implementation ForumContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *html = self.item.content;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.userContentController = [[WKUserContentController alloc]init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    [webView loadHTMLString:html baseURL:nil];
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
