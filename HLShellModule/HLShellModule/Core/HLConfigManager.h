//
//  HLConfigManager.h
//  HLShellModule
//
//  Created by Liang on 2018/4/27.
//

#import <Foundation/Foundation.h>
#import <HLExtensions/HLDefines.h>

@class HLCloudConfig;

@interface HLConfigManager : NSObject

HLDeclareSingletonMethod(defaultManager)

- (void)hl_configLeanCloudAppKey:(NSString *)leanCloundAppKey
           leanCloudClientKey:(NSString *)leanCloudClientKey
                      pushKey:(NSString *)pushKey
       contentViewControllers:(NSArray *)viewControllers;

@property (nonatomic,copy,readonly) NSArray *viewControllers;

- (void)hl_startNetworkObserver:(void(^)(BOOL reachable,HLCloudConfig *cloudConfig))handler;

- (BOOL)hl_isChineseLanguage;

- (void)hl_writeSchemesToFile;

@end
