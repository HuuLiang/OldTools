//
//  HLPaymentNetworkingManager.m
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import "HLPaymentNetworkingManager.h"
#import "HLPaymentHttpClient.h"
#import "NSString+extend.h"
#import "NSObject+extend.h"
#import "HLPaymentInfo.h"
#import "HLPaymentConfiguration.h"
#import "HLPayPoint.h"

static NSString *const kHLPaymentCryptPassword = @"wdnxs&*@#!*qb)*&qiang";

static NSString *const kHLPaymentTestServer = @"http://116.62.124.39/paycenter";
static NSString *const kHLPaymentProductionServer = @"http://pay.rdgongcheng.cn/paycenter";

static NSString *const kHLPaymentConfigurationURL = @"/appPayConfig.json";
static NSString *const kHLPayPointsURL = @"/payPoints.json";


//static NSString *const kHLQueryOrderServer = @"http://phas.rdgongcheng.cn/pd-has";
static NSString *const kHLQueryOrderURL = @"/succOrders.json";

static NSString *const kHLPaymentConfigCacheFile = @"paymentconfiguration";
static NSString *const kHLPayPointsCacheFile = @"paypoints";

@interface HLPaymentNetworkingManager ()
@property (nonatomic,retain) dispatch_queue_t cacheQueue;
@property (nonatomic,retain) NSString *paymentConfigurationCachedPath;
@property (nonatomic,retain) NSString *payPointsCachedPath;
@end

@implementation HLPaymentNetworkingManager

HLSynthesizeSingletonMethod(defaultManager)

- (dispatch_queue_t)cacheQueue {
    if (_cacheQueue) {
        return _cacheQueue;
    }
    
    _cacheQueue = dispatch_queue_create("com.HLpayment.HLPaymentNetworkingManager.cachequeue", nil);
    return _cacheQueue;
}

- (NSString *)paymentConfigurationCachedPath {
    if (_paymentConfigurationCachedPath) {
        return _paymentConfigurationCachedPath;
    }
    
    NSArray<NSString *> *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (cachePaths.firstObject) {
        _paymentConfigurationCachedPath = [NSString stringWithFormat:@"%@/%@", cachePaths.firstObject, kHLPaymentConfigCacheFile.md5];
    }
    return _paymentConfigurationCachedPath;
}

- (NSString *)payPointsCachedPath {
    if (_payPointsCachedPath) {
        return _payPointsCachedPath;
    }
    
    NSArray<NSString *> *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (cachePaths.firstObject) {
        _payPointsCachedPath = [NSString stringWithFormat:@"%@/%@", cachePaths.firstObject, kHLPayPointsCacheFile.md5];
    }
    return _payPointsCachedPath;
}

- (NSString *)absoluteURLStringWithURLPath:(NSString *)urlPath forTest:(BOOL)isTest {
    return [NSString stringWithFormat:@"%@%@", isTest ? kHLPaymentTestServer : kHLPaymentProductionServer, urlPath];
}

- (BOOL)validateParametersForSigning {
    return HLP_STRING_IS_NOT_EMPTY(self.appId) && HLP_STRING_IS_NOT_EMPTY(self.channelNo) && self.pv;
}

- (void)request_fetchPaymentConfigurationWithCompletionHandler:(HLPaymentResultHandler)completionHandler
{
    if (![self validateParametersForSigning]) {
        HLSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    HLPaymentResultHandler successHandler = ^(BOOL usingCache, id obj) {
        NSDictionary *response = [self decryptResponse:obj];
        HLog(@"Fetch payment configuration with response:\n%@", response);
        
        NSNumber *code = response[@"code"];
        if (!code || code.unsignedIntegerValue != 100) {
            HLSafelyCallBlock(completionHandler, NO, response);
            return ;
        }
        
        HLPaymentConfiguration *config = [HLPaymentConfiguration objectFromDictionary:response];
        if (config && !usingCache) {
            dispatch_async(self.cacheQueue, ^{
                BOOL isCached = [(NSDictionary *)obj writeToFile:self.paymentConfigurationCachedPath atomically:YES];
                if (isCached) {
                    HLog(@"✅Cached payment configuration to path : %@!✅", self.paymentConfigurationCachedPath);
                } else {
                    HLog(@"‼️Fail to cache payment configuration to path : %@‼️", self.paymentConfigurationCachedPath);
                }
                
            });
        }
        HLSafelyCallBlock(completionHandler, config != nil, config);
    };
    
    HLPaymentHttpCompletionHandler handler = ^(id obj, NSError *error) {
        if (error) {
            HLSafelyCallBlock(completionHandler, NO, nil);
        } else {
            successHandler(NO, obj);
        }
    };
    
    NSDictionary *encryptedParams = [self encryptParams:@{@"appId":self.appId,
                                                          @"channelNo":self.channelNo,
                                                          @"pv":self.pv}];
    
    @weakify(self);
    [[HLPaymentHttpClient sharedClient] POST:[self absoluteURLStringWithURLPath:kHLPaymentConfigurationURL forTest:self.useTestServer]
                                  withParams:encryptedParams
                           completionHandler:^(id obj, NSError *error)
     {
         @strongify(self);
         if (error) {
             NSDictionary *cachedConfig = [[NSDictionary alloc] initWithContentsOfFile:self.paymentConfigurationCachedPath];
             if (cachedConfig) {
                 successHandler(YES, cachedConfig);
             } else {
                 handler(obj, error);
             }
         } else {
             handler(obj, error);
         }
     }];
}

- (void)request_fetchPayPointsWithCompletionHandler:(HLPaymentResultHandler)completionHandler {
    if (HLP_STRING_IS_EMPTY(self.appId) || !self.payPointVersion || HLP_STRING_IS_EMPTY(self.channelNo)) {
        HLSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    HLPaymentResultHandler success = ^(BOOL usingCache, id obj) {
        
        HLog(@"✅Fetched pay points: %@ %@✅", obj, usingCache ? @"by cache" : @"");
        
        
        NSMutableDictionary *payPoints = [[NSMutableDictionary alloc] init];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary<NSString *, NSArray<NSDictionary *> *> *response = obj;
            [response enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSDictionary *> * _Nonnull obj, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSArray class]]) {
                    return ;
                }
                
                NSArray<HLPayPoint *> *arr = [HLPayPoint objectsFromArray:obj];
                [payPoints setObject:arr forKey:key];
            }];
        }
        
        if (payPoints.count > 0 && !usingCache) {
            dispatch_async(self.cacheQueue, ^{
                BOOL isCached = [(NSDictionary *)obj writeToFile:self.payPointsCachedPath atomically:YES];
                if (isCached) {
                    HLog(@"✅Cached pay points to path : %@!✅", self.paymentConfigurationCachedPath);
                } else {
                    HLog(@"‼️Fail to cache pay points to path : %@‼️", self.paymentConfigurationCachedPath);
                }
                
            });
        }
        HLSafelyCallBlock(completionHandler, YES, payPoints);
    };
    
    NSDictionary *encryptedParams = [self encryptParams:@{@"appId":self.appId,
                                                             @"pointVersion":self.payPointVersion,
                                                             @"channelNo":self.channelNo}];
    [[HLPaymentHttpClient plainRequestClient] POST:[self absoluteURLStringWithURLPath:kHLPayPointsURL forTest:self.useTestServer]
                                        withParams:encryptedParams
                                 completionHandler:^(id obj, NSError *error)
     {
         NSDictionary *resp = [self decryptResponse:obj];
         if ([resp[@"code"] unsignedIntegerValue] == 100 && [resp[@"data"] isKindOfClass:[NSDictionary class]]) {
             success(NO, resp[@"data"]);
         } else {
             NSArray *cachedResults = [[NSArray alloc] initWithContentsOfFile:self.payPointsCachedPath];
             if (cachedResults.count > 0) {
                 success(YES, cachedResults);
             } else {
                 HLSafelyCallBlock(completionHandler, NO, nil);
             }
         }
     }];
}

- (void)request_queryOrders:(NSString *)orders
      withCompletionHandler:(HLPaymentResultHandler)completionHandler
{
    if (HLP_STRING_IS_EMPTY(orders)) {
        HLSafelyCallBlock(completionHandler, NO, nil);
        return ;
    }
    
    NSDictionary *encryptedParams = [self encryptParams:@{@"orderId":orders}];
    
    [[HLPaymentHttpClient sharedClient] POST:[self absoluteURLStringWithURLPath:kHLQueryOrderURL forTest:self.useTestServer]
                                  withParams:encryptedParams
                           completionHandler:^(id obj, NSError *error)
     {
         NSString *response = [self decryptResponse:obj];
         
         HLog(@"Manual activation response : %@", response);
         HLSafelyCallBlock(completionHandler, response.length > 0, response);
     }];
}

- (NSDictionary *)encryptParams:(id)params {

    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *paramString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (paramString.length == 0) {
        return nil;
    }

    NSString *encryption = [paramString encryptedStringWithPassword:[kHLPaymentCryptPassword.md5 substringToIndex:16]];
    if (encryption.length == 0) {
        return nil;
    }

    return @{@"data":encryption};
}


- (id)decryptResponse:(id)response {
    NSString *respString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if (respString.length == 0) {
        return nil;
    }
    
    NSString *decryptedString = [respString decryptedStringWithPassword:[kHLPaymentCryptPassword.md5 substringToIndex:16]];
    if (decryptedString.length == 0) {
        return nil;
    }
    
    id respObject = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return respObject;
}
@end
