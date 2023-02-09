//
//  HLPaymentNetworkingManager.h
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import <Foundation/Foundation.h>
#import "HLPaymentDefines.h"

@interface HLPaymentNetworkingManager : NSObject

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *channelNo;
@property (nonatomic) NSNumber *pv;
@property (nonatomic) NSNumber *payPointVersion;

@property (nonatomic) BOOL useTestServer; //Only for payment configuration and paypoints


HLDeclareSingletonMethod(defaultManager)

- (void)request_fetchPaymentConfigurationWithCompletionHandler:(HLPaymentResultHandler)completionHandler;
- (void)request_fetchPayPointsWithCompletionHandler:(HLPaymentResultHandler)completionHandler;

- (void)request_queryOrders:(NSString *)orders withCompletionHandler:(HLPaymentResultHandler)completionHandler;

@end
