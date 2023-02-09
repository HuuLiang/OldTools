//
//  HLOrderInfo.h
//  Pods
//
//  Created by Liang on 2018/4/14.
//

#import <Foundation/Foundation.h>
#import "HLPaymentDefines.h"

@interface HLOrderInfo : NSObject

@property (nonatomic) NSString *orderId;
@property (nonatomic) NSUInteger orderPrice;  //以分为单位
@property (nonatomic) NSString *orderDescription;
@property (nonatomic) HLPaymentType payType;
@property (nonatomic) NSUInteger maxDiscount;  // 最大减免金额，单位：角

@property (nonatomic) NSString *createTime;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSUInteger currentPayPointType;
@property (nonatomic) NSUInteger targetPayPointType;
@property (nonatomic) NSString *reservedData;


@end
