//
//  HLPaymentManager.m
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import "HLPaymentManager.h"
#import "HLPaymentNetworkingManager.h"
#import "HLPaymentPlugin.h"
#import "HLPaymentPluginManager.h"
#import <NSObject+extend.h>

//NSString *const kHLPaymentWillBeginPaymentNotification = @"com.hlpayment.notification.willbeginpayment";
NSString *const kHLPaymentDidFetchPaymentConfigNotification = @"com.hlpayment.notification.didfetchpaymentconfig";
NSString *const kHLPaymentDidFetchPaymentPointsNotification = @"com.hlpayment.notification.didfetchpaymentpoints";

NSString *const kHLPaymentSettingChannelNo = @"com.hlpayment.settings.channelNo";
NSString *const kHLPaymentSettingAppId = @"com.hlpayment.settings.appId";
NSString *const kHLPaymentSettingPv = @"com.hlpayment.settings.pv";
NSString *const kHLPaymentSettingPayPointVersion = @"com.hlpayment.settings.paypointversion";
NSString *const kHLPaymentSettingUrlScheme = @"com.hlpayment.settings.urlscheme";
NSString *const kHLPaymentSettingDefaultTimeount = @"com.hlpayment.settings.defaulttimeout";
NSString *const kHLPaymentSettingUseConfigInTestServer = @"com.hlpayment.settings.useconfigintestserver";
NSString *const kHLPaymentSettingDefaultConfig = @"com.hlpayment.settings.defaultconfig";

@interface HLPaymentManager ()
@property (nonatomic,weak) HLPaymentPlugin *payingPlugin;
@property (nonatomic,retain) HLPayPoints *fetchedPayPoints;
@property (nonatomic) BOOL fetchedRemotePaymentConfiguration;
@end

@implementation HLPaymentManager

+ (instancetype)sharedManager {
    static HLPaymentManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)registerPaymentWithSettings:(NSDictionary *)settings {
    
    NSString *channelNo = settings[kHLPaymentSettingChannelNo];
    NSString *appId = settings[kHLPaymentSettingAppId];
    NSNumber *pv = settings[kHLPaymentSettingPv];
    NSNumber *payPointVersion = settings[kHLPaymentSettingPayPointVersion];
    
    NSAssert(HLP_STRING_IS_NOT_EMPTY(channelNo) && HLP_STRING_IS_NOT_EMPTY(appId) && pv, @"‼️ChannelNo/AppId/pv must NOT be empty in the settings‼️");
    
    [HLPaymentNetworkingManager defaultManager].channelNo = channelNo;
    [HLPaymentNetworkingManager defaultManager].appId = appId;
    [HLPaymentNetworkingManager defaultManager].pv = pv;
    [HLPaymentNetworkingManager defaultManager].payPointVersion = payPointVersion;
    
    [[HLPaymentPluginManager sharedManager] loadAllPlugins];
    
    // For default payment configuration
    HLPaymentConfiguration *defaultConfiguration;
    if (settings[kHLPaymentSettingDefaultConfig]) {
        id defaultConfig = settings[kHLPaymentSettingDefaultConfig];
        
        if ([defaultConfig isKindOfClass:[NSString class]]) {
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:defaultConfig ofType:@"plist"];
            defaultConfig = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        }
        
        if ([defaultConfig isKindOfClass:[NSDictionary class]]) {
            defaultConfiguration = [HLPaymentConfiguration objectFromDictionary:defaultConfig];
            
        } else if ([defaultConfig isKindOfClass:[HLPaymentConfiguration class]]) {
            defaultConfiguration = defaultConfig;
        }
    }
    
    if (defaultConfiguration) {
        [HLPaymentPluginManager sharedManager].paymentConfiguration = defaultConfiguration;
    }
    // End
    
    [HLPaymentPluginManager sharedManager].urlScheme = settings[kHLPaymentSettingUrlScheme];
    
    if (settings[kHLPaymentSettingUseConfigInTestServer]) {
        [HLPaymentNetworkingManager defaultManager].useTestServer = [settings[kHLPaymentSettingUseConfigInTestServer] boolValue];
    }
    
    [self refreshPaymentConfigurationWithCompletionHandler:nil];
    [self fetchPayPointsWithCompletionHandler:nil];
}

- (void)payWithOrderInfo:(HLOrderInfo *_Nonnull)orderInfo
             contentInfo:(HLContentInfo *_Nullable)contentInfo
                payPoint:(HLPayPoint *_Nullable)payPoint
       completionHandler:(HLPaymentCompletionHandler _Nonnull )completionHandler
{
    // Validate the conditions
    if (orderInfo.payType == HLPaymentTypeNone || HLP_STRING_IS_EMPTY(orderInfo.orderId) || orderInfo.orderPrice == 0) {
        HLog(@"‼️Invalid order!‼️");
        return ;
    }
    
    if (self.fetchedRemotePaymentConfiguration) {
        [self _payWithOrderInfo:orderInfo contentInfo:contentInfo payPoint:payPoint completionHandler:completionHandler];
    } else {
        [self refreshPaymentConfigurationWithCompletionHandler:^(BOOL success, id obj) {
            [self _payWithOrderInfo:orderInfo contentInfo:contentInfo payPoint:payPoint completionHandler:completionHandler];
        }];
    }
}

- (void)payWithOrderInfo:(HLOrderInfo *)orderInfo
             contentInfo:(HLContentInfo *)contentInfo
       completionHandler:(HLPaymentCompletionHandler)completionHandler
{
    [self payWithOrderInfo:orderInfo contentInfo:contentInfo payPoint:nil completionHandler:completionHandler];
}

- (void)_payWithOrderInfo:(HLOrderInfo *_Nonnull)orderInfo
              contentInfo:(HLContentInfo *_Nullable)contentInfo
                 payPoint:(HLPayPoint *_Nullable)payPoint
        completionHandler:(HLPaymentCompletionHandler _Nonnull )completionHandler
{
    HLPluginType pluginType = [self pluginTypeForPaymentType:orderInfo.payType];
    if (pluginType == HLPluginTypeNone) {
        HLog(@"‼️No configured plugin type for payment type: %ld‼️", (unsigned long)orderInfo.payType);
        HLSafelyCallBlock(completionHandler, HLPayResultFailure, nil);
        return ;
    }
    
    // 1. Build payment info from orderInfo and contentInfo
    HLPaymentInfo *paymentInfo = [[HLPaymentInfo alloc] initWithOrderInfo:orderInfo contentInfo:contentInfo payPoint:payPoint];
    paymentInfo.pluginType = pluginType;
    [paymentInfo save];
    
    // 2. Find the plugin to process this order
    HLPaymentPlugin *plugin = [[HLPaymentPluginManager sharedManager] pluginWithType:paymentInfo.pluginType];
    if (!plugin) {
        HLSafelyCallBlock(completionHandler, HLPayResultFailure, paymentInfo);
        return ;
    } else {
        self.payingPlugin = plugin;
    }
    
    // 3. Do payment
    [plugin payWithPaymentInfo:paymentInfo completionHandler:^(HLPayResult payResult, HLPaymentInfo *paymentInfo) {
        self.payingPlugin = nil;
        HLSafelyCallBlock(completionHandler, payResult, paymentInfo);
    }];
}

- (void)activatePaymentInfos:(NSArray<HLPaymentInfo *> *_Nonnull)paymentInfos
       withCompletionHandler:(HLPaymentResultHandler _Nullable )completionHandler {
    
    NSMutableString *orders = [NSMutableString string];
    [paymentInfos enumerateObjectsUsingBlock:^(HLPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (orders.length > 0) {
            [orders appendString:@"|"];
        }
        
        if (obj.orderId.length > 0) {
            [orders appendString:obj.orderId];
        }
        
    }];
    
    [[HLPaymentNetworkingManager defaultManager] request_queryOrders:orders
                                               withCompletionHandler:^(BOOL success, id obj)
     {
         __block HLPaymentInfo *paymentInfo;
         if (success) {
             NSString *orderId = obj;
             
             if ([orderId isKindOfClass:[NSString class]]) {
                 
                 NSArray<NSString *> *paidOrders = [orderId componentsSeparatedByString:@"|"];
                 [paymentInfos enumerateObjectsUsingBlock:^(HLPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([paidOrders containsObject:obj.orderId]) {
                         paymentInfo = obj;
                         *stop = YES;
                     }
                 }];
             }
         }
         
         HLSafelyCallBlock(completionHandler, success, paymentInfo);
     }];
}

- (void)refreshPaymentConfigurationWithCompletionHandler:(HLPaymentResultHandler)completionHandler {
    [[HLPaymentNetworkingManager defaultManager] request_fetchPaymentConfigurationWithCompletionHandler:^(BOOL success, id obj) {
        if (success) {
            self.fetchedRemotePaymentConfiguration = YES;
            [HLPaymentPluginManager sharedManager].paymentConfiguration = obj;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHLPaymentDidFetchPaymentConfigNotification object:obj];
        }
        
        HLSafelyCallBlock(completionHandler, success, obj);
    }];
}

@end

@implementation HLPaymentManager (PluginQueries)

- (HLPaymentConfigurationDetail *)configurationDetailOfPaymentType:(HLPaymentType)paymentType {
    HLPaymentConfiguration *configuration = [HLPaymentPluginManager sharedManager].paymentConfiguration;
    
    if (paymentType == HLPaymentTypeWeChat) {
        return configuration.weixin;
    } else if (paymentType == HLPaymentTypeAlipay) {
        return configuration.alipay;
    } else {
        return nil;
    }
}

- (BOOL)pluginIsEnabled:(HLPluginType)pluginType {
    return [[HLPaymentPluginManager sharedManager] pluginIsEnabled:pluginType];
}

- (HLPluginType)pluginTypeForPaymentType:(HLPaymentType)paymentType {
    return [self configurationDetailOfPaymentType:paymentType].type.unsignedIntegerValue;
}

- (NSUInteger)minialPriceForPaymentType:(HLPaymentType)paymentType {
    HLPluginType pluginType = [self pluginTypeForPaymentType:paymentType];
    
    HLPaymentPlugin *plugin = [[HLPaymentPluginManager sharedManager] pluginWithType:pluginType];
    return plugin.minimalPrice;
}

- (NSArray<NSNumber *> *)allSupportedPaymentTypes {
    return @[@(HLPaymentTypeWeChat),
             @(HLPaymentTypeAlipay)];
}

- (NSArray<NSNumber *> *)availablePaymentTypes {
    NSMutableDictionary<NSNumber *, HLPaymentConfigurationDetail *> *details = [NSMutableDictionary dictionary];
    
    [[self allSupportedPaymentTypes] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HLPaymentConfigurationDetail *detail = [self configurationDetailOfPaymentType:obj.unsignedIntegerValue];
        if (detail && [self pluginIsEnabled:detail.type.unsignedIntegerValue]) {
            [details setObject:detail forKey:obj];
        }
    }];
    
    if (details.count == 0) {
        return nil;
    }
    
    return [details keysSortedByValueUsingComparator:^NSComparisonResult(HLPaymentConfigurationDetail *obj1, HLPaymentConfigurationDetail *obj2) {
        CGFloat discount1 = obj1.discount && obj1.discount.floatValue != 0 ? obj1.discount.floatValue : 1;
        CGFloat discount2 = obj2.discount && obj2.discount.floatValue != 0 ? obj2.discount.floatValue : 1;
        return [@(discount1) compare:@(discount2)];
    }];
}

- (NSUInteger)discountOfPaymentType:(HLPaymentType)paymentType {
    NSNumber *discount = [self configurationDetailOfPaymentType:paymentType].discount;
    if (!discount || discount.floatValue == 0) {
        return 100;
    }
    
    CGFloat discountPercent = discount.floatValue * 100;
    return lroundf(discountPercent);
}
@end

@implementation HLPaymentManager (PayPoints)

- (void)fetchPayPointsWithCompletionHandler:(HLPaymentResultHandler)completionHandler {
    @weakify(self);
    [[HLPaymentNetworkingManager defaultManager] request_fetchPayPointsWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (success) {
            self.fetchedPayPoints = obj;
            [[NSNotificationCenter defaultCenter] postNotificationName:kHLPaymentDidFetchPaymentPointsNotification object:obj];
        }
        HLSafelyCallBlock(completionHandler, success, obj);
    }];
}

- (HLPayPoints *)payPoints {
    return self.fetchedPayPoints;
}

@end

@implementation HLPaymentManager (ApplicationCallback)

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.payingPlugin applicationWillEnterForeground:application];
}

- (void)handleOpenUrl:(NSURL *)url {
    [self.payingPlugin handleOpenURL:url];
}

@end
