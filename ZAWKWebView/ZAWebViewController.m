//
//  ZAWebViewController.m
//  ZAWKWebView
//
//  Created by 张奥 on 2019/10/18.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ZAWebViewController.h"
#import "ZAWeakScriptMessageDelegate.h"
#import <WebKit/WebKit.h>

static NSInteger timeoutInterval = 1;

static NSString *const rightButton = @"rightButton";
static NSString *const closeWebView = @"closeWebView";

@interface ZAWebViewController ()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
//网页函数
@property (nonatomic, copy) NSString *exampleHandleOne;
@property (nonatomic, copy) NSString *exampleHandleTwo;

//网页加载进度
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation ZAWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationItem.hidesBackButton = YES;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0 , 0, 44, 44);
    leftButton.backgroundColor = [UIColor redColor];
    
    // 设置leftBarButtonItem
    UIBarButtonItem *leftItem =[[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0 , 0, 44, 44);
    rightButton.backgroundColor = [UIColor redColor];
    
    // 设置rightBarButtonItem
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self configWebView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 80, 80);
    [button setTitle:@"刷新" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 8.f;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(clickRefreshButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpButton.frame = CGRectMake(200, 200, 80, 80);
    [jumpButton setTitle:@"回跳指定网页" forState:UIControlStateNormal];
    jumpButton.backgroundColor = [UIColor redColor];
    jumpButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [jumpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    jumpButton.layer.cornerRadius = 8.f;
    jumpButton.layer.masksToBounds = YES;
    [jumpButton addTarget:self action:@selector(clickJumpButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpButton];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2)];
    progressView.backgroundColor = [UIColor blueColor];
    self.progressView = progressView;
    progressView.transform = CGAffineTransformMakeScale(1.0, 1.5);
    [self.view addSubview:progressView];
    //KVO监听进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)clickRightButton{
    if (self.webView.canGoForward) {
        [self.webView goForward];
//        [self.webView stopLoading];
    }
    
}

-(void)clickLeftButton{
    
    if (self.webView.canGoBack) {
        [self.webView goBack];
//        [self.webView stopLoading];
    }else{
        if ([self isPushController]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)clickJumpButton{
    
    if ([self markWebItem] != nil) {
        [self.webView goToBackForwardListItem:[self markWebItem]];
    }
}

-(void)clickRefreshButton{
    //重新请求加载网页到指定的URL
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.tencent.com"]]];
    //刷新单前的网页
//    [self.webView reload];
    //如果网页里数据有变化则刷新,没有则取缓存数据
      [self.webView reloadFromOrigin];
}

//配置webView
-(void)configWebView{
    //网页配置
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    //网页偏好设置
    configuration.preferences = [[WKPreferences alloc] init];
    //是否允许js交互
    configuration.preferences.javaScriptEnabled = YES;
    //在没有交互的情况下打开自动打开窗口,默认为NO
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //最小字体
    configuration.preferences.minimumFontSize = 15;
    //添加cookie参数
//    NSMutableDictionary *cookDic = [NSMutableDictionary new];
//    [cookDic setObject:@(SharedData.user.userId) forKey:@"userId"];
//    [cookDic setObject:SharedData.user.userKey forKey:@"userKey"];
//    [cookDic setObject:SharedData.channelNumber forKey:@"channel"];
//    [cookDic setObject:[KLUtil appVersion] forKey:@"version"];
//    [cookDic setObject:ShareAppInfo.buildId forKey:@"packageName"];
//
//    NSInteger role = SharedData.user.categoryId>1?2:1;
//    [cookDic setObject:@(role) forKey:@"role"];
//
//    if (webSourceId > 0) {
//        [cookDic setObject:@(webSourceId) forKey:@"sourceId"];
//    }
//    if (_nobleId) { //有贵族, 则添加进cookie
//        [cookDic setObject:@(_nobleId) forKey:@"nobleId"];
//    }
//
//    NSString *jsonString = [NSString convertToJsonData:cookDic];
    //添加cookie
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"document.cookie = 'vchat=%@';", @"jsonString"] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    //用户交互控制器
    WKUserContentController *uerConrtroll = [[WKUserContentController alloc] init];
    [uerConrtroll addUserScript:cookieScript];
    //添加js函数,设置代理
    [uerConrtroll addScriptMessageHandler:[[ZAWeakScriptMessageDelegate alloc] initWithDelegate:self] name:rightButton];
    [uerConrtroll addScriptMessageHandler:[[ZAWeakScriptMessageDelegate alloc] initWithDelegate:self] name:closeWebView];
    configuration.userContentController = uerConrtroll;
    //网页视图
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.frame = self.view.bounds;
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    self.webView = webView;
    [self.view addSubview:webView];
    //url加载网页
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval]];
    //配置,防止网页偏移
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark -- 网页加载进度KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }
}

#pragma mark -- 客户端调用js的函数
//不带参数
-(void)handleOneJsMethod{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@()",self.exampleHandleOne] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
       NSLog(@"javaScript错误%@------%@",response,error);
    }];
}
//带参数
-(void)handleTwoMethodParam:(NSString *)paramsOne paramsTwo:(NSString *)paramsTwo{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@','%@')",self.exampleHandleTwo,paramsOne,paramsTwo] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"javaScript错误%@------%@",response,error);
    }];
}

#pragma mark -- WKScriptMessageHandler
//收到js的函数后客户端做处理
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //js的调用函数
    NSString *messageName = message.name;
    //js回调中带的参数字典
    NSDictionary *messageDic = [self parseJsonStringToOBJDictionary:message.body];
    if ([messageName isEqualToString:rightButton]) {
       //点击网页上右边的按钮
        if (messageDic) {
        //后面客户端需要调用的js函数
         self.exampleHandleOne = messageDic[@"handle"];
        }
    }else if ([messageName isEqualToString:closeWebView]){
        if (messageDic) {
            //后面客户端需要调用的js函数
            self.exampleHandleTwo = messageDic[@"handle"];
        }
        //点击网页关闭
        if ([self isPushController]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark -- WKUIDelegate
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"网页关闭了");
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //是否允许这个导航栏
//    NSLog(@"%@",navigationAction.targetFrame);
    decisionHandler(WKNavigationActionPolicyAllow);
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    NSLog(@"%@",navigationResponse.response);
    decisionHandler(WKNavigationResponsePolicyAllow);
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"开始加载");
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"加载失败");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"网页开始接受网页内容");
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"网页导航栏加载完毕");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = self.webView.title;
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"----document.title:%@---webView title:%@",response,self.webView.title);
    }];
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
}

-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSLog(@"网页加载内容进程终止");
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
}

-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"跳转到其他服务器");
}
//标记跳转到指定的网页
-(WKBackForwardListItem*)markWebItem{
    NSArray *historyItem = [self.webView.backForwardList backList];
    for (int i = 0; i<historyItem.count; i++) {
        WKBackForwardListItem *item = historyItem[i];
        if ([item.title isEqualToString:@"百度一下"]) {
            return item;
        }
    }
    return nil;
}
//解析前端的json数据
-(NSDictionary*)parseJsonStringToOBJDictionary:(NSString*)jsonStr{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    if (![responseDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return responseDic;
}
//判断控制器是present还是push
-(BOOL)isPushController{
    if (self.presentingViewController) {
        //present
        return NO;
    }else{
        //push
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
