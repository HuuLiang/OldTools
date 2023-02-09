//
//  HLSNSQQManager.m
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import "HLSNSQQManager.h"
#import "HLSNSQQUser.h"
#import <NSObject+BaseRepresentation.h>
#import <HLDefines.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface HLSNSQQManager () <TencentSessionDelegate>
@property (nonatomic,retain) TencentOAuth *auth;
@property (nonatomic,copy) HLSNSCompletionHandler completionHandler;
@end

@implementation HLSNSQQManager

HLSynthesizeSingletonMethod(sharedManager)

- (void)setConfiguration:(NSDictionary *)configuration {
    NSString *appId = configuration[kHLSNSConfigurationAppID];
    NSAssert(appId.length > 0, @"The configuration of QQ should have a valid appId!");
    
    self.auth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    self.auth.authShareType = AuthShareType_QQ;
}

- (void)loginInViewController:(UIViewController *)viewController withCompletionHandler:(HLSNSCompletionHandler)completionHandler {
    self.completionHandler = completionHandler;
    [self.auth authorize:@[kOPEN_PERMISSION_GET_SIMPLE_USER_INFO] inSafari:NO];
}

- (void)handleOpenURL:(NSURL *)url {
    [TencentOAuth HandleOpenURL:url];
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin {
    if (self.auth.accessToken.length > 0) {
        [self.auth getUserInfo];
    } else {
        NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain code:kHLSNSLoginInvalidAccessTokenOrOpenIdError userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败：无效的Access Token或Open ID！"}];
        HLSafelyCallBlock(self.completionHandler, nil, error);
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain code:cancelled ? kHLSNSLoginUserAuthCancelledError : kHLSNSLoginUnknownError userInfo:@{NSLocalizedDescriptionKey:cancelled?@"QQ登录失败：用户取消登录！":@"QQ登录失败：未知错误！"}];
    HLSafelyCallBlock(self.completionHandler, nil, error);
}

- (void)tencentDidNotNetWork {
    NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain code:kHLSNSLoginNetworkError userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败：网络错误！"}];
    HLSafelyCallBlock(self.completionHandler, nil, error);
}

- (void)getUserInfoResponse:(APIResponse *)response {
    if (response && response.retCode == URLREQUEST_SUCCEED) {
        
        NSDictionary *userInfo = [response jsonResponse];
        HLSNSQQUser *user = [HLSNSQQUser objectFromDictionary:userInfo];
        user.openid = self.auth.openId;
        
        if (user) {
            HLSafelyCallBlock(self.completionHandler, user, nil);
        } else {
            NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain code:kHLSNSLoginUserInfoFailureError userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败：无效的用户信息！"}];
            HLSafelyCallBlock(self.completionHandler, nil, error);
        }
    } else {
        NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain code:kHLSNSLoginUserInfoFailureError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"QQ登录失败：%@(错误码：%d)！", response.errorMsg, response.retCode]}];
        HLSafelyCallBlock(self.completionHandler, nil, error);
    }
}

@end
