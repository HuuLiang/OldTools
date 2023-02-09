//
//  HLPaymentConfiguration.h
//  HLPayment
//
//  Created by Liang on 2018/4/16.
//

#import <Foundation/Foundation.h>
#import "HLPaymentConfigurationDetail.h"

@interface HLPaymentConfiguration : NSObject

@property (nonatomic,retain) HLPaymentConfigurationDetail *alipay;
@property (nonatomic,retain) HLPaymentConfigurationDetail *weixin;

@end
