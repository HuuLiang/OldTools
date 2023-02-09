//
//  HLSNSLogin.h
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "HLSNSDefines.h"
#import "HLSNSConfigurable.h"

@protocol HLSNSLogin <NSObject>

@required
- (void)loginInViewController:(UIViewController *)viewController withCompletionHandler:(HLSNSCompletionHandler)completionHandler;
- (void)handleOpenURL:(NSURL *)url;

@end
