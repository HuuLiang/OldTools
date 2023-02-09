//
//  HLSNSConfigurable.h
//  HLSNSKit
//
//  Created by Liang on 2018/1/11.
//

#import <Foundation/Foundation.h>

@protocol HLSNSConfigurable <NSObject>

@required
- (void)setConfiguration:(NSDictionary *)configuration;

@end
