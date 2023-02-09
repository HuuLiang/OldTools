//
//  HLPaymentInfo.h
//  HLPayment
//
//  Created by Liang on 2018/4/14.
//

#import <Foundation/Foundation.h>
#import "HLPaymentDefines.h"

@class HLOrderInfo;
@class HLContentInfo;
@class HLPayPoint;

@interface HLPaymentInfo : NSObject

@property (nonatomic) NSString *orderId;
@property (nonatomic) NSUInteger orderPrice;  //以分为单位
@property (nonatomic) NSString *orderDescription;

@property (nonatomic) HLPluginType pluginType;
@property (nonatomic) HLPaymentType paymentType;
@property (nonatomic) HLPayPointType payPointType;
@property (nonatomic) HLPayPointType currentPayPointType;
@property (nonatomic) HLPayPointType targetPayPointType;
@property (nonatomic) NSString *paymentTime;
@property (nonatomic) NSString *reservedData;

@property (nonatomic) HLPayResult paymentResult;
@property (nonatomic) HLPayStatus paymentStatus;

@property (nonatomic) NSNumber *contentId;
@property (nonatomic) NSNumber *contentType;
@property (nonatomic) NSNumber *contentLocation;
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *columnType;
@property (nonatomic) NSString *userId;

@property (nonatomic) NSNumber *version;

@property (nonatomic,retain) HLPayPoint *payPoint;

+ (NSArray<HLPaymentInfo *> *)allPaymentInfos;
- (instancetype)initWithOrderInfo:(HLOrderInfo *)orderInfo contentInfo:(HLContentInfo *)contentInfo;
- (instancetype)initWithOrderInfo:(HLOrderInfo *)orderInfo contentInfo:(HLContentInfo *)contentInfo payPoint:(HLPayPoint *)payPoint;
//+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment;
- (void)save;

@end
