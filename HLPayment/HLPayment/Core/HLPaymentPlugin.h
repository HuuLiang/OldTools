//
//  HLPaymentPlugin.h
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import <Foundation/Foundation.h>
#import "HLPaymentDefines.h"
#import "HLPaymentInfo.h"

@interface HLPaymentPlugin : NSObject

@property (nonatomic) HLPluginType pluginType;
@property (nonatomic) NSString *pluginName;
@property (nonatomic,retain) NSDictionary *paymentConfiguration;
@property (nonatomic) NSString *urlScheme;

@property (nonatomic,retain) HLPaymentInfo *paymentInfo;
@property (nonatomic,copy) HLPaymentCompletionHandler paymentCompletionHandler;
@property (nonatomic,retain) UIViewController *payingViewController;

- (UIViewController *)viewControllerForPresentingPayment;
- (NSString *)deviceName;
- (NSString *)IPAddress;

- (void)queryPaymentResultForPaymentInfo:(HLPaymentInfo *)paymentInfo withRetryTimes:(NSUInteger)retryTimes completionHandler:(HLPaymentCompletionHandler)completionHandler;
- (void)endPaymentWithPayResult:(HLPayResult)payResult;

@end

@interface HLPaymentPlugin (SubclassingHooks)

- (void)pluginDidLoad;
- (void)pluginDidSetPaymentConfiguration:(NSDictionary *)paymentConfiguration;

- (void)payWithPaymentInfo:(HLPaymentInfo *)paymentInfo completionHandler:(HLPaymentCompletionHandler)completionHandler;

- (void)handleOpenURL:(NSURL *)url;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (NSUInteger)minimalPrice;
- (BOOL)shouldRequirePhotoLibraryAuthorization;

@end

@interface HLPaymentPlugin (Loading)

- (void)beginLoading;
- (void)endLoading;

@end
