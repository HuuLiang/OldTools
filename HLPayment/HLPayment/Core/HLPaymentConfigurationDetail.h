//
//  HLPaymentConfigurationDetail.h
//  HLPayment
//
//  Created by Liang on 2018/4/14.
//

#import <Foundation/Foundation.h>

@interface HLPaymentConfigurationDetail : NSObject

@property (nonatomic) NSNumber *type;
@property (nonatomic) NSDictionary *config;
@property (nonatomic) NSNumber *discount;

@end
