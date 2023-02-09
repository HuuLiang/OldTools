//
//  AlipayPlugin.m
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import "AlipayPlugin.h"
#import "AlipayOrder.h"
#import <AlipaySDK/AlipaySDK.h>
#import <RSADataSigner.h>

@interface AlipayPlugin ()
@property (nonatomic) NSString *seller;
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;
@end

@implementation AlipayPlugin

- (HLPluginType)pluginType {
    return HLPluginTypeAlipay;
}

- (NSString *)pluginName {
    return @"支付宝";
}

- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    self.appId = paymentConfiguration[@"appId"];
    self.signKey = paymentConfiguration[@"privateKey"];
    self.notifyUrl = paymentConfiguration[@"notifyUrl"];
    self.seller = paymentConfiguration[@"seller"];
}

- (void)payWithPaymentInfo:(HLPaymentInfo *)paymentInfo completionHandler:(HLPaymentCompletionHandler)completionHandler {
    if (HLP_STRING_IS_EMPTY(self.appId) || HLP_STRING_IS_EMPTY(self.signKey) || HLP_STRING_IS_EMPTY(self.notifyUrl) || HLP_STRING_IS_EMPTY(self.seller) || HLP_STRING_IS_EMPTY(self.urlScheme) || HLP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        HLSafelyCallBlock(completionHandler, HLPayResultFailure, paymentInfo);
        return ;
    }
    
    AlipayOrder *order = [[AlipayOrder alloc] init];
    // NOTE: app_id设置
    order.app_id = self.appId;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = @"RSA2";
    
    order.notify_url = self.notifyUrl;
    order.passback_params = paymentInfo.reservedData;
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = paymentInfo.orderDescription;
    order.biz_content.subject = paymentInfo.orderDescription;
    order.biz_content.out_trade_no = paymentInfo.orderId; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", paymentInfo.orderPrice / 100.]; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    HLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:self.signKey];
    NSString *signedString = [signer signString:orderInfo withRSA2:YES];
    
    //    if ((rsa2PrivateKey.length > 1)) {
    //        signedString = [signer signString:orderInfo withRSA2:YES];
    //    } else {
    //        signedString = [signer signString:orderInfo withRSA2:NO];
    //    }
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        @weakify(self);
        self.paymentCompletionHandler = completionHandler;
        self.paymentInfo = paymentInfo;
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:self.urlScheme callback:^(NSDictionary *resultDic) {
            @strongify(self);
            [self onAlipayCallback:resultDic];
        }];
    } else {
        HLog(@"‼️AlipayPlugin: 签名失败!‼️");
        HLSafelyCallBlock(completionHandler, HLPayResultFailure, paymentInfo);
    }
}

- (void)handleOpenURL:(NSURL *)url {
    @weakify(self);
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        @strongify(self);
        HLog(@"AlipayPlugin response:\n%@", resultDic);
        [self onAlipayCallback:resultDic];
    }];
}

- (void)onAlipayCallback:(NSDictionary *)resultDic {
    NSString *resultStatus = resultDic[@"resultStatus"];
    
    HLPayResult payResult = HLPayResultFailure;
    if ([resultStatus isEqualToString:@"6001"]) {
        payResult = HLPayResultCancelled;
    } else if ([resultStatus isEqualToString:@"9000"]) {
        payResult = HLPayResultSuccess;
    }
    
    if (self.paymentInfo) {
        HLSafelyCallBlock(self.paymentCompletionHandler, payResult, self.paymentInfo);
    }
    
    self.paymentCompletionHandler = nil;
    self.paymentInfo = nil;
}
@end
