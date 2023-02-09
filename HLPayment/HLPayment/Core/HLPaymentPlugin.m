//
//  HLPaymentPlugin.m
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import "HLPaymentPlugin.h"
#import "AFNetworking.h"
#import "HLPaymentNetworkingManager.h"
#import <sys/sysctl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <MBProgressHUD.h>
#import <NSString+extend.h>

@interface HLPaymentPlugin ()

@end

@implementation HLPaymentPlugin

- (NSString *)pluginName {
    if (_pluginName) {
        return _pluginName;
    }
    
    _pluginName = NSStringFromClass([self class]);
    return _pluginName;
}

- (void)setPaymentConfiguration:(NSDictionary *)paymentConfiguration {
    _paymentConfiguration = paymentConfiguration;
    
    [self pluginDidSetPaymentConfiguration:paymentConfiguration];
}

- (NSUInteger)minimalPrice {
    return 100;
}

- (void)pluginDidLoad {}
- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration {}

- (void)payWithPaymentInfo:(HLPaymentInfo *)paymentInfo completionHandler:(HLPaymentCompletionHandler)completionHandler {
    self.paymentInfo = paymentInfo;
    self.paymentCompletionHandler = completionHandler;
}

- (void)handleOpenURL:(NSURL *)url {}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.paymentInfo) {
        @weakify(self);
        [self beginLoading];
        [self queryPaymentResultForPaymentInfo:self.paymentInfo
                                withRetryTimes:3
                             completionHandler:^(HLPayResult payResult, HLPaymentInfo *paymentInfo)
         {
             @strongify(self);
             [self endPaymentWithPayResult:payResult];
             
         }];
    }
}

- (BOOL)shouldRequirePhotoLibraryAuthorization {
    return NO;
}

- (void)queryPaymentResultForPaymentInfo:(HLPaymentInfo *)paymentInfo
                          withRetryTimes:(NSUInteger)retryTimes
                       completionHandler:(HLPaymentCompletionHandler)completionHandler
{
    if (HLP_STRING_IS_EMPTY(paymentInfo.orderId)) {
        HLSafelyCallBlock(completionHandler, HLPayResultUnknown, paymentInfo);
        return ;
    }
    
    if (retryTimes == 0) {
        return ;
    }
    
    [[HLPaymentNetworkingManager defaultManager] request_queryOrders:paymentInfo.orderId
                                               withCompletionHandler:^(BOOL success, id obj)
     {
         if (success) {
             HLSafelyCallBlock(completionHandler, HLPayResultSuccess, paymentInfo);
         } else if (retryTimes == 1) {
             HLSafelyCallBlock(completionHandler, HLPayResultFailure, paymentInfo);
         } else {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                 [self queryPaymentResultForPaymentInfo:paymentInfo
                                         withRetryTimes:retryTimes-1
                                      completionHandler:completionHandler];
             });
         }
         
     }];
}

- (void)endPaymentWithPayResult:(HLPayResult)payResult {
    [self endLoading];
    
    HLPaymentInfo *paymentInfo = self.paymentInfo;
    if (!paymentInfo) {
        return ;
    }
    
    UIViewController *payingVC = self.payingViewController;
    
    self.paymentInfo = nil;
    self.payingViewController = nil;
        
    if (payingVC) {
        [payingVC dismissViewControllerAnimated:YES completion:^{
            
            HLSafelyCallBlock(self.paymentCompletionHandler, payResult, paymentInfo);
            
            self.paymentCompletionHandler = nil;
        }];
    } else {
        HLSafelyCallBlock(self.paymentCompletionHandler, payResult, paymentInfo);
        
        self.paymentCompletionHandler = nil;
    }
}

- (UIViewController *)viewControllerForPresentingPayment {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

- (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

- (NSString *)IPAddress {
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)beginLoading {
    if (![MBProgressHUD HUDForView:[UIApplication sharedApplication].delegate.window]) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
}

- (void)endLoading {
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
}

- (NSString *)uniqueString {
    NSString *unique = [NSUUID UUID].UUIDString.md5;
    if (HLP_STRING_IS_EMPTY(unique)) {
        unique = @([[NSDate date] timeIntervalSince1970]).stringValue.md5;
    }
    return unique;
}
@end
