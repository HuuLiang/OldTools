//
//  HLPayInfoCell.h
//  HLPayment_Example
//
//  Created by Liang on 2018/4/21.
//  Copyright © 2018年 757437150@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLPayInfoCell : UITableViewCell

+ (NSString *)defaultReusebleIdentifier;

@property (nonatomic,copy) NSString *content;

@end
