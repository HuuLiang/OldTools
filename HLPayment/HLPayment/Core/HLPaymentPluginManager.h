//
//  HLPaymentPluginManager.h
//  HLPayment
//
//  Created by Liang on 2018/4/17.
//

#import <Foundation/Foundation.h>
#import "HLPaymentPlugin.h"
#import "HLPaymentConfiguration.h"

@interface HLPaymentPluginManager : NSObject

@property (nonatomic,retain) HLPaymentConfiguration *paymentConfiguration;
@property (nonatomic) NSString *urlScheme;

+ (instancetype)sharedManager;

- (void)loadAllPlugins;

// Plugin Queries
- (NSArray<HLPaymentPlugin *> *)allPlugins;
- (HLPaymentPlugin *)pluginWithType:(HLPluginType)pluginType;
- (BOOL)pluginIsEnabled:(HLPluginType)pluginType;

@end
