//
//  HLSNSManager.h
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "HLSNSDefines.h"

@interface HLSNSManager : NSObject

+ (instancetype)sharedManager;

// The option of the configuration can be kQBSNSConfigurationAppID or kQBSNSConfigurationSecret.
- (void)registerSNSWithType:(HLSNSType)type configuration:(NSDictionary *)configuration;
- (void)loginSNSWithType:(HLSNSType)type
        inViewController:(UIViewController *)viewController
       completionHandler:(HLSNSCompletionHandler)completionHandler;

- (void)handleOpenURL:(NSURL *)url;

@end
