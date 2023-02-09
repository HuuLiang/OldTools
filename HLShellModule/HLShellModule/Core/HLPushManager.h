//
//  HLPushManager.h
//  HLShellModule
//
//  Created by Liang on 2018/4/25.
//

#import <Foundation/Foundation.h>
#import <HLExtensions/HLDefines.h>
#import <MLSOAppDelegate/MLSOAppDelegate.h>

@interface HLPushManager : NSObject <MLAppService>

HLDeclareSingletonMethod(defaultManager)


/** 注册推送
 [self registerJPushWithAppKey:@"c8adc484a883aba7add5c18c" launchOptions:launchOptions];
 @param appKey 极光推送appkey
 @param launchOptions
 */
- (void)hl_registerJPushWithAppKey:(NSString *)appKey;


@end
