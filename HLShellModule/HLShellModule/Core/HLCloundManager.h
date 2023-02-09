//
//  HLCloundManager.h
//  HLShellModule
//
//  Created by Liang on 2018/4/24.
//

#import <Foundation/Foundation.h>
#import <MLSOAppDelegate/MLSOAppDelegate.h>
#import <HLExtensions/HLDefines.h>

@interface HLCloudConfig : NSObject
@property (nonatomic,copy) NSString *appid;
@property (nonatomic,copy) NSNumber *show;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *pushKey;
@property (nonatomic,copy) NSNumber *skipEnable;
//RN

@end


@protocol HLCloudConfigDelegate <NSObject>

@optional
- (void)hl_fetchConfig:(void(^)(HLCloudConfig *cloudConfig))handler;

@end


@interface HLCloundManager : NSObject <MLAppService>

HLDeclareSingletonMethod(defaultManager)

/**
 注册LeanCloud
 @param appId leanCloudAppId
 @param clientKey LeandCloudClientKey
 */
- (void)hl_registerLeanCloudAppId:(NSString *)appId clientKey:(NSString *)clientKey;

- (void)hl_queryCloudLetAppSkipWithUrl:(void(^)(HLCloudConfig *cloudConfig))handler;

@property (nonatomic,readonly) HLCloudConfig *config;

@property (nonatomic,weak) id <HLCloudConfigDelegate> delegate;

@end

