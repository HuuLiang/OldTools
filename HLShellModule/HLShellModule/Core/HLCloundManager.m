//
//  HLCloundManager.m
//  HLShellModule
//
//  Created by Liang on 2018/4/24.
//

#import "HLCloundManager.h"

#import "NSObject+extend.h"

#import <AVOSCloud/AVOSCloud.h>
#import <BmobSDK/Bmob.h>

#define QueryClassName           @"config"
#define BUNDLE_IDENTIFIER        ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]))
#define Bundle_id                @"appid"
#define BmobDataKey              @"dataDic"

//默认不可见。私有配置信息
#define BmobCloudAppKey          @"e3b2a49b58477da250acae0422222bba"

#define LeanDataKey              @"localData"


@interface HLCloundManager ()
@property (nonatomic,strong) HLCloudConfig *config;
@property (nonatomic,retain) dispatch_group_t dispatchGroup;
@end

@implementation HLCloundManager

HLSynthesizeSingletonMethod(defaultManager)

SynthesizeContainerPropertyElementClassMethod(config, HLCloudConfig)

+ (void)load {
    [[MLAppServiceManager sharedManager] registerService:[self defaultManager]];
}

- (NSString *)serviceName {
    return NSStringFromClass([self class]);
}

- (dispatch_group_t)dispatchGroup {
    if (_dispatchGroup) {
        return _dispatchGroup;
    }
    
    _dispatchGroup = dispatch_group_create();
    return _dispatchGroup;
}

//网络开启之后注册云后台信息
- (void)hl_registerLeanCloudAppId:(NSString *)appId clientKey:(NSString *)clientKey {
    [Bmob registerWithAppKey:BmobCloudAppKey];
    [AVOSCloud setVerbosePolicy:kAVVerboseNone];
    [AVOSCloud setApplicationId:appId clientKey:clientKey];
}

- (void)hl_queryCloudLetAppSkipWithUrl:(void (^)(HLCloudConfig *))handler {
    
    const NSUInteger dataRequestCount = 2;
    for (NSUInteger i = 0; i < dataRequestCount; ++i) {
        dispatch_group_enter(self.dispatchGroup);
    }
    
    //获取LeanCloud配置设置 公开配置
    __block HLCloudConfig *leanConfig = nil;
    if ([self.delegate respondsToSelector:@selector(fetchConfig:)]) {
        [self.delegate hl_fetchConfig:^(HLCloudConfig *cloudConfig) {
            leanConfig = cloudConfig;
            leanConfig.skipEnable = @(YES);
            dispatch_group_leave(self.dispatchGroup);
        }];
    } else {
        AVQuery *avQuery = [AVQuery queryWithClassName:QueryClassName];
//        [avQuery whereKey:Bundle_id equalTo:BUNDLE_IDENTIFIER]; //服务器耗时严重 不建议使用此条查询规则 返回所有数据自己判断
        [avQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //获取带指定bundleid的第一条数据 默认公开配置允许跳转
                HLCloudConfig *config = [HLCloudConfig objectFromDictionary:[obj valueForKey:LeanDataKey]];
                if ([config.appid isEqualToString:BUNDLE_IDENTIFIER]) {
                    leanConfig = config;
                    leanConfig.skipEnable = @(YES);
                    *stop = YES;
                }
            }];
            dispatch_group_leave(self.dispatchGroup);
        }];
    }
    
    //获取BmobCloud配置设置 私有配置
    __block HLCloudConfig *bmobConfig = nil;
    BmobQuery *bmobQuery = [BmobQuery queryWithClassName:QueryClassName];
//    [bmobQuery whereKey:Bundle_id equalTo:BUNDLE_IDENTIFIER]; //服务器耗时严重 不建议使用此条查询规则 返回所有数据自己判断
    [bmobQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取带指定bundleid的第一条数据
            HLCloudConfig *config = [HLCloudConfig objectFromDictionary:[obj valueForKey:BmobDataKey]];
            if ([config.appid isEqualToString:BUNDLE_IDENTIFIER]) {
                bmobConfig = config;
                *stop = YES;
            }
        }];
        dispatch_group_leave(self.dispatchGroup);
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)10* NSEC_PER_SEC));
        dispatch_async(dispatch_get_main_queue(), ^{
            leanConfig.skipEnable = bmobConfig.skipEnable;
            self.config = leanConfig;
            HLSafelyCallBlock(handler,leanConfig);
        });
    });

    
}

@end


@implementation HLCloudConfig

@end
