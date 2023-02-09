//
//  HLSNSQQManager.h
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "HLSNSLogin.h"

@interface HLSNSQQManager : NSObject <HLSNSLogin>

+ (instancetype)sharedManager;

@end
