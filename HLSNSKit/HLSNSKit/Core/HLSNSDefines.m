//
//  HLSNSDefines.m
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import "HLSNSDefines.h"

NSString *const kHLSNSConfigurationAppID = @"appId";
NSString *const kHLSNSConfigurationSecret = @"secret";

NSString *const kHLSNSLoginErrorDomain = @"com.HLstore.errordomain.wechatlogin";

const NSInteger kHLSNSLoginSDKCallFailureError = -1;
const NSInteger kHLSNSLoginUserAuthRejectedError = -4;
const NSInteger kHLSNSLoginUserAuthCancelledError = -2;
const NSInteger kHLSNSLoginUnknownError = NSIntegerMin;
const NSInteger kHLSNSLoginUserInfoFailureError = -5;
const NSInteger kHLSNSLoginInvalidAccessTokenOrOpenIdError = -6;
const NSInteger kHLSNSLoginNetworkError = -999;
