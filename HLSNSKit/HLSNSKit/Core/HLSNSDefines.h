//
//  HLSNSDefines.h
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#ifndef HLSNSDefines_h
#define HLSNSDefines_h

typedef NS_ENUM(NSUInteger, HLSNSType) {
    HLSNSTypeNone,
    HLSNSTypeWeChat,
    HLSNSTypeQQ
};

// SNS Configuration Keys
FOUNDATION_EXPORT NSString *const kHLSNSConfigurationAppID;
FOUNDATION_EXPORT NSString *const kHLSNSConfigurationSecret;

// Block types
typedef void (^HLSNSCompletionHandler)(id obj, NSError *error);

// Error Domain
FOUNDATION_EXPORT NSString *const kHLSNSLoginErrorDomain;

// Error Codes
FOUNDATION_EXPORT const NSInteger kHLSNSLoginSDKCallFailureError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginUserAuthRejectedError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginUserAuthCancelledError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginUserInfoFailureError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginInvalidAccessTokenOrOpenIdError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginNetworkError;
FOUNDATION_EXPORT const NSInteger kHLSNSLoginUnknownError;


#endif /* HLSNSDefines_h */
