//
//  HLPaymentHttpClient.h
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import <Foundation/Foundation.h>

typedef void (^HLPaymentHttpCompletionHandler)(id obj, NSError *error);

@interface HLPaymentHttpClient : NSObject

+ (instancetype)sharedClient;
+ (instancetype)plainRequestClient;
+ (instancetype)JSONRequestClient;
+ (instancetype)XMLRequestClient;

- (void)GET:(NSString *)url withParams:(id)params completionHandler:(HLPaymentHttpCompletionHandler)completionHandler;
- (void)POST:(NSString *)url withParams:(id)params completionHandler:(HLPaymentHttpCompletionHandler)completionHandler;
- (void)POST:(NSString *)url withXMLText:(NSString *)xmlText completionHandler:(HLPaymentHttpCompletionHandler)completionHandler;

@end

// Error Domain
extern NSString *const kHLPaymentHttpClientErrorDomain;

// Invalid argument error code
extern const NSInteger kHLPaymentHttpClientInvalidArgument;
