//
//  HLPaymentManager.h
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import <Foundation/Foundation.h>
#import "HLPaymentDefines.h"
#import "HLOrderInfo.h"
#import "HLContentInfo.h"
#import "HLPayPoint.h"

@interface HLPaymentManager : NSObject

+ (instancetype _Nonnull)sharedManager;

- (void)registerPaymentWithSettings:(NSDictionary *_Nonnull)settings;

- (void)payWithOrderInfo:(HLOrderInfo *_Nonnull)orderInfo
             contentInfo:(HLContentInfo *_Nullable)contentInfo
       completionHandler:(HLPaymentCompletionHandler _Nonnull )completionHandler;

- (void)payWithOrderInfo:(HLOrderInfo *_Nonnull)orderInfo
             contentInfo:(HLContentInfo *_Nullable)contentInfo
                payPoint:(HLPayPoint *_Nullable)payPoint
       completionHandler:(HLPaymentCompletionHandler _Nonnull )completionHandler;

- (void)activatePaymentInfos:(NSArray<HLPaymentInfo *> *_Nonnull)paymentInfos
       withCompletionHandler:(HLPaymentResultHandler _Nullable )completionHandler;

- (void)refreshPaymentConfigurationWithCompletionHandler:(HLPaymentResultHandler _Nullable )completionHandler;

@end

@interface HLPaymentManager (PluginQueries)

- (BOOL)pluginIsEnabled:(HLPluginType)pluginType;
- (HLPluginType)pluginTypeForPaymentType:(HLPaymentType)paymentType;
- (NSUInteger)minialPriceForPaymentType:(HLPaymentType)paymentType;

- (NSArray<NSNumber *> *_Nullable)availablePaymentTypes;
- (NSUInteger)discountOfPaymentType:(HLPaymentType)paymentType;  // discount is represented by percent, e.g. 90 means 90% discount

@end

@interface HLPaymentManager (PayPoints)

@property (nonatomic,retain,readonly) HLPayPoints * _Nullable payPoints;

- (void)fetchPayPointsWithCompletionHandler:(HLPaymentResultHandler _Nullable)completionHandler;

@end

@interface HLPaymentManager (ApplicationCallback)

- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application;
- (void)handleOpenUrl:(NSURL *_Nonnull)url;

@end

// Keys of payment options
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingChannelNo;
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingAppId;
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingPv;
FOUNDATION_EXPORT NSString * _Nonnull const kHLPaymentSettingPayPointVersion;

// 支付app回调的url scheme
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingUrlScheme;

// 默认的超时时间，单位秒
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingDefaultTimeount;

// 指定默认的支付配置信息, value可以是HLPaymentConfiguration或者NSDictionary或者NSString(plist文件名，不包含扩展名)的实例
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingDefaultConfig;

// 是否使用测试环境的支付配置信息， value为BOOL类型
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentSettingUseConfigInTestServer;

// Notifications
//FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentWillBeginPaymentNotification;
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentDidFetchPaymentConfigNotification;
FOUNDATION_EXTERN NSString * _Nonnull const kHLPaymentDidFetchPaymentPointsNotification;
