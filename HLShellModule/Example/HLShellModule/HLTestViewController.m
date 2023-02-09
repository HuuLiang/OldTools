//
//  HLTestViewController.m
//  HLShellModule_Example
//
//  Created by Liang on 2018/4/27.
//  Copyright © 2018年 757437150@qq.com. All rights reserved.
//

#import "HLTestViewController.h"
#import <Masonry.h>

@interface HLTestViewController ()

@end

@implementation HLTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    label.text = @"测试小马甲";
    label.textColor = [UIColor blueColor];
    label.backgroundColor = [UIColor grayColor];
    [self.view addSubview:label];
    
    {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
