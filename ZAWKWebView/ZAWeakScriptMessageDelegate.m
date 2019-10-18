//
//  ZAWeakScriptMessageDelegate.m
//  ZAWKWebView
//
//  Created by 张奥 on 2019/10/18.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ZAWeakScriptMessageDelegate.h"

@implementation ZAWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
