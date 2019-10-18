//
//  ViewController.m
//  ZAWKWebView
//
//  Created by 张奥 on 2019/10/18.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ViewController.h"
#import "ZAWebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"主页";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 80, 80);
    [button setTitle:@"点我" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 8.f;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (IBAction)clickButton:(id)sender {
    
    ZAWebViewController *VC = [[ZAWebViewController alloc] init];
    VC.urlStr = @"https://www.baidu.com";
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
