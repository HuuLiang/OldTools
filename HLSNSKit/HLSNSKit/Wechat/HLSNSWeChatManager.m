//
//  HLSNSWeChatManager.m
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import "HLSNSWeChatManager.h"
#import <AFNetworking.h>
#import <HLDefines.h>
#import <NSObject+BaseRepresentation.h>
#import <WechatOpenSDK/WXApi.h>
#import <WechatOpenSDK/WXApiObject.h>
#import "HLSNSWeChatUser.h"

static NSString *const kWeChatAuthState = @"HLSNSWeChatAuth";
static NSString *const kWeChatAccessTokenURL = @"https://api.weixin.qq.com/sns/oauth2/access_token";
static NSString *const kWeChatUserInfoURL = @"https://api.weixin.qq.com/sns/userinfo";

@interface HLSNSWeChatManager () <WXApiDelegate>
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *secret;
@property (nonatomic,copy) HLSNSCompletionHandler loginCompletionHandler;
@end

@implementation HLSNSWeChatManager

HLSynthesizeSingletonMethod(sharedManager)

- (void)setConfiguration:(NSDictionary *)configuration {
    
    NSString *appId = configuration[kHLSNSConfigurationAppID];
    NSString *secret = configuration[kHLSNSConfigurationSecret];
    NSAssert(appId.length > 0 && secret.length > 0, @"The configuration of WeChat should have a valid appId and secret!");
    
    _appId = appId;
    _secret = secret;
}

- (void)loginInViewController:(UIViewController *)viewController withCompletionHandler:(HLSNSCompletionHandler)completionHandler {
    
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = kWeChatAuthState ;
    
    BOOL success = NO;
    [WXApi registerApp:self.appId];
    if ([WXApi isWXAppInstalled]) {
        success = [WXApi sendReq:req];
    } else {
        success = [WXApi sendAuthReq:req viewController:viewController delegate:self];
    }
    
    if (success) {
        self.loginCompletionHandler = completionHandler;
    } else {
        NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                             code:kHLSNSLoginSDKCallFailureError
                                         userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：无法打开微信登录"}];
        HLLog(@"%@", error.localizedDescription);
        HLSafelyCallBlock(completionHandler, nil, error);
    }
}

- (void)handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
}

- (AFHTTPSessionManager *)newSessionManager {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
    return sessionManager;
}

- (void)onSuccessfullyRespondLoginWithCode:(NSString *)loginCode {
    NSDictionary *accessTokenParams = @{@"appid":self.appId, @"secret":self.secret, @"code":loginCode, @"grant_type":@"authorization_code"};
    
    @weakify(self);
    [[self newSessionManager] GET:kWeChatAccessTokenURL
                       parameters:accessTokenParams
                         progress:nil
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSString *accessToken = responseObject[@"access_token"];
         NSString *openid = responseObject[@"openid"];
         
         if (accessToken == nil || openid == nil) {
             NSError *err = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                                code:kHLSNSLoginInvalidAccessTokenOrOpenIdError
                                            userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：无效的Access Token或Open ID"}];
             HLLog(@"%@", err.localizedDescription);
             HLSafelyCallBlock(self.loginCompletionHandler, nil, err);
             return ;
         }
         
         [[self newSessionManager] GET:kWeChatUserInfoURL
                            parameters:@{@"access_token":accessToken,
                                         @"openid":openid}
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
          {
              @strongify(self);
              NSDictionary *resp = responseObject;
              NSNumber *errorCode = resp[@"errcode"];
              NSString *errorMessage = resp[@"errmsg"];
              
              if (errorCode) {
                  NSError *error = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                                       code:kHLSNSLoginUserInfoFailureError
                                                   userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"微信登录失败：%@(错误码：%@)", errorMessage, errorCode]}];
                  HLLog(@"%@", error.localizedDescription);
                  HLSafelyCallBlock(self.loginCompletionHandler, nil, error);
                  return ;
              }
              
              HLSNSWeChatUser *user = [HLSNSWeChatUser objectFromDictionary:resp];
              HLSafelyCallBlock(self.loginCompletionHandler, user, nil);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSError *err = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                                 code:kHLSNSLoginNetworkError
                                             userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：网络问题"}];
              HLLog(@"%@", err.localizedDescription);
              HLSafelyCallBlock(self.loginCompletionHandler, nil, err);
          }];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSError *err = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                            code:kHLSNSLoginNetworkError
                                        userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：网络问题"}];
         HLLog(@"%@", err.localizedDescription);
         HLSafelyCallBlock(self.loginCompletionHandler, nil, err);
     }];
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.errCode == 0) {
            [self onSuccessfullyRespondLoginWithCode:authResp.code];
        } else {
            NSError *error;
            if (authResp.errCode == kHLSNSLoginUserAuthRejectedError) {
                error = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                            code:kHLSNSLoginUserAuthRejectedError
                                        userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：用户拒绝授权"}];
            } else if (authResp.errCode == kHLSNSLoginUserAuthCancelledError) {
                error = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                            code:kHLSNSLoginUserAuthCancelledError
                                        userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：用户取消授权"}];
            } else {
                error = [NSError errorWithDomain:kHLSNSLoginErrorDomain
                                            code:kHLSNSLoginUnknownError
                                        userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：未知错误"}];
            }
            
            HLLog(@"%@", error.localizedDescription);
            HLSafelyCallBlock(self.loginCompletionHandler, nil, error);
            self.loginCompletionHandler = nil;
        }
    }
}

@end
