//
//  ZAWeakScriptMessageDelegate.h
//  ZAWKWebView
//
//  Created by 张奥 on 2019/10/18.
//  Copyright © 2019 张奥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface ZAWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
