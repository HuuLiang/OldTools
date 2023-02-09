//
//  HLPaymentDefines.h
//  Pods
//
//  Created by Liang on 2018/4/14.
//

#ifndef HLPaymentDefines_h
#define HLPaymentDefines_h

#import "HLDefines.h"


typedef NS_ENUM(NSUInteger, HLPluginType) {
    HLPluginTypeNone,
    HLPluginTypeAlipay = 1001,
    HLPluginTypeWeChatPay = 1008,
//    HLPluginTypeIAppPay = 1009, //爱贝支付
//    HLPluginTypeVIAPay = 1010, //首游时空
//    HLPluginTypeWFTPay = 1012, //威富通
//    HLPluginTypeHTPay = 1015, //海豚支付
//    HLPluginTypeMTDLPay = 1017, //明天动力
//    HLPluginTypeMingPay = 1018, //明鹏支付
//    HLPluginTypeDXTXPay = 1019, //盾行天下
//    HLPluginTypeWJPay = 1020, // 无极支付
//    HLPluginTypeWeiYingPay = 1022, //微赢支付
//    HLPluginTypeXLTXPay = 1023, //星罗天下
//    HLPluginTypeJSPay = 1028, //杰莘
//    HLPluginTypeHeePay = 1029,     //汇付宝
//    HLPluginTypeMLYPay = 1030, // 萌乐游
//    HLPluginTypeLSPay = 1031, // 雷胜app支付
//    HLPluginTypeRMPay = 1032, // 融梦支付
//    HLPluginTypeZRPay = 1033, // 中润付(甬润支付)
//    HLPluginTypeYiPay = 1034, // 易支付
//    HLPluginTypeLSScanPay = 1035, //雷胜扫码支付
//    HLPluginTypeDXTXScanPay = 1036, //盾行天下扫码支付
//    HLPluginTypeLePay = 1037,    //乐Pay
//    HLPluginTypeJiePay = 1038,   //捷支付
//    HLPluginTypeHaiJiaPay = 1039, //海嘉支付
    HLPluginTypeUnknown = 9999
};

typedef NSUInteger HLPayPointType;

typedef NS_ENUM(NSUInteger, HLPaymentType) {
    HLPaymentTypeNone,
    HLPaymentTypeWeChat,
    HLPaymentTypeAlipay,
    HLPaymentTypeUPPay,
    HLPaymentTypeQQ
};

typedef NS_ENUM(NSInteger, HLPayResult)
{
    HLPayResultSuccess   = 0,
    HLPayResultFailure   = 1,
    HLPayResultCancelled = 2,
    HLPayResultUnknown   = 3
};

typedef NS_ENUM(NSUInteger, HLPayStatus) {
    HLPayStatusUnknown,
    HLPayStatusPaying,
    HLPayStatusNotProcessed,
    HLPayStatusProcessed
};

@class HLPaymentInfo;
typedef void (^HLPaymentCompletionHandler)(HLPayResult payResult, HLPaymentInfo *paymentInfo);
typedef void (^HLPaymentResultHandler)(BOOL success,id obj);

#define HLPDEPRECATED(desc) __attribute__((unavailable(desc)))

#define HLP_STRING_IS_EMPTY(str) (str.length==0)
#define HLP_STRING_IS_NOT_EMPTY(str) (str.length>0)

#define HLP_XML_CDATA(rdata) [NSString stringWithFormat:@"<![CDATA[%@]]>", rdata]
#define HLP_XML_RAWDATA(cdata) ([cdata hasPrefix:@"<![CDATA["] ? [cdata substringWithRange:NSMakeRange(9, [cdata length]-12)] : cdata)


#endif /* HLPaymentDefines_h */
