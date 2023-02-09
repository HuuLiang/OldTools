//
//  HLConfigManager.m
//  HLShellModule
//
//  Created by Liang on 2018/4/27.
//

#import "HLConfigManager.h"
#import <HLExtensions/HLNetworkClient.h>

#import "HLPushManager.h"
#import "HLCloundManager.h"

#define simplified_Chinese @"zh-Hans-CN"
#define Chiness_Area       @"zh"

@interface HLConfigManager ()
@property (nonatomic,copy) NSString *leanCloundAppKey;
@property (nonatomic,copy) NSString *leanCloudClientKey;
@property (nonatomic,copy) NSArray *viewControllers;
@property (nonatomic,strong) HLCloudConfig *cloudConfig;
@end

@implementation HLConfigManager

HLSynthesizeSingletonMethod(defaultManager)


- (void)hl_configLeanCloudAppKey:(NSString *)leanCloundAppKey
           leanCloudClientKey:(NSString *)leanCloudClientKey
                      pushKey:(NSString *)pushKey
       contentViewControllers:(NSArray *)viewControllers {
    _leanCloundAppKey       = leanCloundAppKey;
    _leanCloudClientKey     = leanCloudClientKey;
    _viewControllers  = viewControllers;
    
    //注册推送
    [[HLPushManager defaultManager] hl_registerJPushWithAppKey:pushKey];
}

- (void)hl_startNetworkObserver:(void (^)(BOOL, HLCloudConfig *))handler {
    [HLNetworkClient sharedClient].reachabilityChangedAction = ^ (BOOL reachable) {
        //网络错误提示
        if ([HLNetworkClient sharedClient].networkStatus <= HLNetworkStatusNotReachable) {
            HLSafelyCallBlock(handler,NO,nil);
        } else {
            if (!self.cloudConfig) {
                //注册云
                [[HLCloundManager defaultManager] hl_registerLeanCloudAppId:self.leanCloundAppKey clientKey:self.leanCloudClientKey];
                //获取云端配置
                @weakify(self);
                [[HLCloundManager defaultManager] hl_queryCloudLetAppSkipWithUrl:^(HLCloudConfig *cloudConfig) {
                    self.cloudConfig = cloudConfig;
                    @strongify(self);
                    //向主界面发送设置信息
                    HLSafelyCallBlock(handler,YES,cloudConfig);
                }];
            }
        }
    };
    [[HLNetworkClient sharedClient] startMonitoring];
}


#pragma mark -区域语言判断
- (BOOL)hl_isChineseLanguage {
    return [[[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2] isEqualToString:Chiness_Area];
}


#pragma mark -

- (void)hl_writeSchemesToFile {
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"HLShellModule-Info" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:pathStr];
    HLog(@"%@",dictionary);
}


@end
