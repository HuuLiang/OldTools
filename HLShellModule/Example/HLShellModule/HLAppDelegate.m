//
//  HLAppDelegate.m
//  HLExtensions
//
//  Created by 757437150@qq.com on 01/10/2018.
//  Copyright (c) 2018 757437150@qq.com. All rights reserved.
//

#import "HLAppDelegate.h"
#import "HLConfigManager.h"
#import "HLTestViewController.h"
#import <HLCloundManager.h>
#import <HLNetworkClient.h>

//#define LeanCloudAppId           @"mC1LBNKYaCE3ftNOSk6GL8zS-gzGzoHsz"
//#define LeanCloudClientKey       @"T59yrO1ct8Js3FhvsmyCcdfs"

@interface HLAppDelegate () <HLCloudConfigDelegate>

@end

@implementation HLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HLConfigManager defaultManager] hl_configLeanCloudAppKey:@"mC1LBNKYaCE3ftNOSk6GL8zS-gzGzoHsz"
                                         leanCloudClientKey:@"T59yrO1ct8Js3FhvsmyCcdfs"
                                                    pushKey:@"c8adc484a883aba7add5c18c"
                                     contentViewControllers:nil];
    [HLCloundManager defaultManager].delegate = self;
    
    if ([super respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
        [super application:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}

#pragma mark - HLCloudConfigDelegate

//- (void)fetchConfig:(void (^)(HLCloudConfig *))handler {
//    [[HLNetworkClient sharedClient] requestURLPath:@"http://www.6122c.com/Lottery_server/get_init_data?appid=com.lotterymsg.app&type=ios" withParams:nil method:HLHttpGETMethod completionHandler:^(id obj, NSError *error) {
//        NSNumber *code = obj[@"type"];
//        if (code.integerValue == 200) {
//            NSDictionary *dic = obj[@"data"];
//            HLCloudConfig *config = [HLCloudConfig new];
//            config.appid = dic[@"appid"];;
//            config.show = @((NSInteger)dic[@"is_jump"] == 1);
//            config.url = dic[@"jump_url"];
//            config.skipEnable = @(YES);
//            HLSafelyCallBlock(handler,config);
//        } else {
//            HLSafelyCallBlock(handler,nil);
//        }
//    }];
//}

@end
