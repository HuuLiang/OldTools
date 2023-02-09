//
//  HLSNSManager.m
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import "HLSNSManager.h"
#import <HLDefines.h>
#import "HLSNSLogin.h"

@interface HLSNSManager ()
@property (nonatomic,retain,readonly) NSDictionary *managerClassNames;
@property (nonatomic,retain) NSMutableDictionary *managers;
@property (nonatomic,weak) id<HLSNSLogin> loginingManager;
@end

@implementation HLSNSManager
HLSynthesizeSingletonMethod(sharedManager)
HLDefineLazyPropertyInitialization(NSMutableDictionary, managers)

- (void)registerSNSWithType:(HLSNSType)type configuration:(NSDictionary *)configuration {
    
    id manager = self.managers[@(type)];
    if (!manager) {
        NSString *className = self.managerClassNames[@(type)];
        NSAssert(className.length > 0, @"No class can handle the SNS type");
        
        Class class = NSClassFromString(className);
        NSAssert(class, @"No class can handle the SNS type");
        
        manager = [[class alloc] init];
        [self.managers setObject:manager forKey:@(type)];
    }
    
    if ([manager conformsToProtocol:@protocol(HLSNSConfigurable)]) {
        id<HLSNSConfigurable> configurableManager = manager;
        [configurableManager setConfiguration:configuration];
    } else {
        NSAssert(NO, @"The SNS manager is NOT configurable!");
    }
}

- (NSDictionary *)managerClassNames {
    return @{@(HLSNSTypeWeChat):@"QBSNSWeChatManager",
             @(HLSNSTypeQQ):@"QBSNSQQManager"};
}

- (void)loginSNSWithType:(HLSNSType)type
        inViewController:(UIViewController *)viewController
       completionHandler:(HLSNSCompletionHandler)completionHandler {
    id manager = self.managers[@(type)];
    NSAssert(manager, @"No manager can handle the SNS type!");
    
    if ([manager conformsToProtocol:@protocol(HLSNSLogin)]) {
        id<HLSNSLogin> loginManager = manager;
        self.loginingManager = loginManager;
        [loginManager loginInViewController:viewController withCompletionHandler:completionHandler];
    } else {
        NSAssert(NO, @"The SNS manager is NOT login enabled!");
    }
}

- (void)handleOpenURL:(NSURL *)url {
    [self.loginingManager handleOpenURL:url];
}

@end
