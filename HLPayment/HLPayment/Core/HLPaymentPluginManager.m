//
//  HLPaymentPluginManager.m
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import "HLPaymentPluginManager.h"
#import "NSString+extend.h"

static NSString *const kHLPaymentConfigurationUserDefaultsKey = @"com.hlpayment.userdefaults.payconfig";
static NSString *const kHLPaymentConfigurationCryptionPassword = @"eiafjsiajo339045$^%&#%@%";

@interface HLPaymentPluginManager ()
@property (nonatomic,retain) NSMutableArray<HLPaymentPlugin *> *plugins;
@property (nonatomic,retain,readonly) NSArray<NSString *> *pluginClassNames;
@end

@implementation HLPaymentPluginManager

HLDefineLazyPropertyInitialization(NSMutableArray, plugins)
HLSynthesizeSingletonMethod(sharedManager)

- (void)loadAllPlugins {
    __block BOOL shouldRequirePhotoLibraryAuthorization = NO;
    [self.pluginClassNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class class = NSClassFromString(obj);
        if ([class isSubclassOfClass:[HLPaymentPlugin class]]) {
            HLPaymentPlugin *plugin = [[class alloc] init];
            [plugin pluginDidLoad];
            [self.plugins addObject:plugin];
            
            if ([plugin shouldRequirePhotoLibraryAuthorization]) {
                shouldRequirePhotoLibraryAuthorization = YES;
            }
            HLog(@"✅✅✅Loaded plugin with name: %@ and ID: %ld", plugin.pluginName, (unsigned long)plugin.pluginType);
        }
    }];
    
#ifdef DEBUG
    if (shouldRequirePhotoLibraryAuthorization) {
        NSString *photoAuth = [NSBundle mainBundle].infoDictionary[@"NSPhotoLibraryUsageDescription"];
        NSAssert(photoAuth, @"⚠️You have integrated LSPay but no NSPhotoLibraryUsageDescription key-value in info.plist, which may lead to a crash if user selects QR code payment and saves the QR image to local photo albums!⚠️\n⚠️你已经集成了雷胜支付，但是并没有在info.plist中添加允许访问图片库的描述，当用户选择扫码支付并且保存二维码到本地图片库的时候，将会导致程序崩溃！⚠️");
    }
    
    NSArray<NSString *> *essentialSchemes = @[@"alipay",@"wechat",@"alipayqr",@"weixin",@"mqq",@"alipays"];
    NSArray<NSString *> *querySchemes = [NSBundle mainBundle].infoDictionary[@"LSApplicationQueriesSchemes"];
    NSMutableArray *excludeSchemes = [NSMutableArray array];
    [essentialSchemes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![querySchemes containsObject:obj]) {
            [excludeSchemes addObject:obj];
        }
    }];
    
    if (excludeSchemes.count > 0) {
        HLog(@"⚠️The schemes: %@ are not found in your info.plist, and the payment may fail to invoke the corresponding apps!⚠️", excludeSchemes);
        HLog(@"⚠️%@的scheme未包含在info.plist中，调起相应的app支付有可能会失败！⚠️", excludeSchemes);
    }
#endif
}

- (void)setPaymentConfiguration:(HLPaymentConfiguration *)paymentConfiguration {
    _paymentConfiguration = paymentConfiguration;
    
    HLPaymentPlugin *weixnPlugin = [self pluginWithType:paymentConfiguration.weixin.type.unsignedIntegerValue];
    weixnPlugin.paymentConfiguration = paymentConfiguration.weixin.config;
    weixnPlugin.urlScheme = self.urlScheme;
    
    HLPaymentPlugin *alipayPlugin = [self pluginWithType:paymentConfiguration.alipay.type.unsignedIntegerValue];
    alipayPlugin.paymentConfiguration = paymentConfiguration.alipay.config;
    alipayPlugin.urlScheme = self.urlScheme;
}

- (void)setUrlScheme:(NSString *)urlScheme {
    _urlScheme = urlScheme;
    
    HLPaymentPlugin *weixnPlugin = [self pluginWithType:self.paymentConfiguration.weixin.type.unsignedIntegerValue];
    weixnPlugin.urlScheme = urlScheme;
    
    HLPaymentPlugin *alipayPlugin = [self pluginWithType:self.paymentConfiguration.alipay.type.unsignedIntegerValue];
    alipayPlugin.urlScheme = urlScheme;
}

- (NSArray<HLPaymentPlugin *> *)allPlugins {
    return self.plugins;
}

- (HLPaymentPlugin *)pluginWithType:(HLPluginType)pluginType {
    __block HLPaymentPlugin *plugin;
    [self.plugins enumerateObjectsUsingBlock:^(HLPaymentPlugin * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pluginType == pluginType) {
            plugin = obj;
            *stop = YES;
        }
    }];
    return plugin;
}

- (BOOL)pluginIsEnabled:(HLPluginType)pluginType {
    return [self pluginWithType:pluginType] != nil;
}

- (NSArray<NSString *> *)pluginClassNames {
    return @[@"WeChatPaymentPlugin",
             @"AlipayPlugin",
             @"IappPaymentPlugin",
             @"VIAPaymentPlugin",
             @"WFTPaymentPlugin",
             @"YiPaymentPlugin",
             @"WJPaymentPlugin",
             @"JiePaymentPlugin",
             @"MingPaymentPlugin",
             @"HaiJiaPaymentPlugin",
             @"DmePaymentPlugin",
             @"HuiPaymentPlugin",
             @"DXTXPaymentPlugin",
             @"ZYPaymentPlugin",
             @"XinPaymentPlugin",
             @"BNPaymentPlugin",
             @"ZGBNPaymentPlugin",
             @"WeiPaymentPlugin",
             @"XXBPaymentPlugin",
             @"BBPaymentPlugin",
             @"LePaymentPlugin",
             @"LBPaymentPlugin",
             @"RocketPaymentPlugin"];
}
@end
