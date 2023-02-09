//
//  LaunchViewController.m
//  HLShellModule
//
//  Created by Liang on 2018/4/25.
//

#import "LaunchViewController.h"

#import "HLConfigManager.h"
#import "HLCloundManager.h"
#import <AXWebViewController.h>
#import <Masonry.h>
#import <HLExtensions/HLHudManager.h>
#import <BlocksKit+UIKit.h>
#import <UIImage+color.h>
#import <UIViewController+showOrHide.h>
//#import <HLExtensions/HLNetworkClient.h>

//#import <HLExtensions/NSObject+extend.h>
//#import "HLPushManager.h"


@interface LaunchViewController ()
@property (nonatomic,strong) UIImageView *networkErrorIamgeView;
@end

@implementation LaunchViewController

#pragma mark - life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadChildViewControllers];
}

- (void)defaultConfiguration {
    self.tabBar.translucent = NO;
    [self.tabBar setShadowImage:[UIImage imageWithColor:[kColor(@"#f2f2f2") colorWithAlphaComponent:0.9]]];
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setBackgroundColor:[kColor(@"#ffffff") colorWithAlphaComponent:0.9]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColor(@"#999999"),NSFontAttributeName:kFont(11)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kColor(@"#63C9CF"),NSFontAttributeName:kFont(11)} forState:UIControlStateSelected];
}

- (void)loadChildViewControllers {
    self.viewControllers = [HLConfigManager defaultManager].viewControllers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[HLHudManager sharedManager] showLoadingInfo:@"正在加载.."];
    @weakify(self);
    [[HLConfigManager defaultManager] hl_startNetworkObserver:^(BOOL reachable, HLCloudConfig *cloudConfig) {
        @strongify(self);
        self.networkErrorIamgeView.hidden = reachable;
        [[HLHudManager sharedManager] hide];
        if (!cloudConfig) {
            if (reachable) {
                
            }
            return ;
        }
        
        if (cloudConfig.skipEnable.boolValue && cloudConfig.show.boolValue && cloudConfig.url.length > 0 && [HLConfigManager defaultManager].hl_isChineseLanguage) {
            [[HLConfigManager defaultManager] hl_writeSchemesToFile];
            [self presentWebViewControllerWithUrl:[NSURL URLWithString:cloudConfig.url]];
        } else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)presentWebViewControllerWithUrl:(NSURL *)url {
    AXWebViewController *webVC = [[AXWebViewController alloc] initWithURL:url];
    webVC.navigationType = AXWebViewControllerNavigationToolItem;
    webVC.showsToolBar = YES;
    UINavigationController *webNav = [[UINavigationController alloc] initWithRootViewController:webVC];
    [self presentViewController:webNav animated:NO completion:nil];
}

#pragma mark - UI
- (UIImageView *)networkErrorIamgeView {
    if (_networkErrorIamgeView) {
        return _networkErrorIamgeView;
    }
    _networkErrorIamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_net.png"]];
    _networkErrorIamgeView.contentMode = UIViewContentModeScaleAspectFit;
    _networkErrorIamgeView.userInteractionEnabled = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_networkErrorIamgeView];
    {
        [_networkErrorIamgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([UIApplication sharedApplication].keyWindow);
        }];
    }
    @weakify(self);
    [_networkErrorIamgeView bk_whenTapped:^{
        @strongify(self);
        [[HLHudManager sharedManager] showInfo:@"正在加载"];
        [[HLHudManager sharedManager] showLoadingInfo:@"正在加载.."];
    }];
    return _networkErrorIamgeView;
}


@end
