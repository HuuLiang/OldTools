//
//  HLViewController.m
//  HLPayment
//
//  Created by 757437150@qq.com on 04/12/2018.
//  Copyright (c) 2018 757437150@qq.com. All rights reserved.
//

#import "HLViewController.h"

#import <objc/runtime.h>

#import <HLPayment/HLPaymentManager.h>
#import <HLPayment/HLPaymentConfiguration.h>
#import <NSObject+extend.h>

#import <Masonry.h>

#import "HLPayInfoCell.h"

#define kHLPaymentUrlScheme @"khlpaymenturlscheme"

typedef NS_ENUM(NSInteger,kHLPaymentInfoSection) {
    kHLPaymentInfoSectionPayConfig = 0,
    kHLPaymentInfoSectionPayPoints,
    kHLPaymentInfoSectionCount
};

@interface HLViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) HLPaymentConfiguration *configuration;
@property (nonatomic,copy) NSMutableArray <HLPayPoint *> *payPoints;
@property (nonatomic,strong) HLPayPoint *payPoint;
@end

@implementation HLViewController
HLDefineLazyPropertyInitialization(NSMutableArray, payPoints)

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPayConfig:) name:kHLPaymentDidFetchPaymentConfigNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPayPoints:) name:kHLPaymentDidFetchPaymentPointsNotification object:nil];
    
    [[HLPaymentManager sharedManager] registerPaymentWithSettings:@{kHLPaymentSettingChannelNo:@"PA_IOS_F000001",
                                                                    kHLPaymentSettingAppId:@"AP0001",
                                                                    kHLPaymentSettingPv:@(100),
                                                                    kHLPaymentSettingPayPointVersion:@(100),
                                                                    kHLPaymentSettingUrlScheme:kHLPaymentUrlScheme,
                                                                    //                                                                    kHLPaymentSettingDefaultConfig:@"PaymentConfig",
#ifdef DEBUG
                                                                    kHLPaymentSettingUseConfigInTestServer:@(YES)
#endif
                                                                    }];
    
}

- (void)loadPayConfig:(NSNotification *)notification {
    self.configuration = [notification object];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kHLPaymentInfoSectionPayConfig] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)loadPayPoints:(NSNotification *)notification {
    HLPayPoints * payPoints = [notification object];
    [self.payPoints removeAllObjects];
    [payPoints enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<HLPayPoint *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.payPoints addObjectsFromArray:obj];
    }];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kHLPaymentInfoSectionPayPoints] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.allowsMultipleSelection = YES;
    [_tableView registerClass:[HLPayInfoCell class] forCellReuseIdentifier:[HLPayInfoCell defaultReusebleIdentifier]];
    [self.view addSubview:_tableView];
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (void)pay:(HLPayPoint *)payPoint {
    HLOrderInfo *orderInfo = [[HLOrderInfo alloc] init];
    orderInfo.orderId = @"xxxxxx";
    orderInfo.orderPrice = payPoint ? payPoint.fee.unsignedIntegerValue : 1;
    orderInfo.orderDescription = @"摩登影院";
    orderInfo.payType = 2;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    orderInfo.createTime = [dateFormatter stringFromDate:[NSDate date]];
    orderInfo.userId = @"Modern Cinema";
    orderInfo.currentPayPointType = 0;
    orderInfo.targetPayPointType = 1;
    orderInfo.reservedData = @"11";
    
    HLContentInfo *contentInfo = [[HLContentInfo alloc] init];
    contentInfo.contentType = @(1);
    contentInfo.contentId = payPoint.id;
    
    __weak typeof(self) weakSelf = self;
    [[HLPaymentManager sharedManager] payWithOrderInfo:orderInfo contentInfo:contentInfo payPoint:payPoint completionHandler:^(HLPayResult payResult, HLPaymentInfo *paymentInfo) {
        NSString *resultTitle = nil;
        if (payResult == HLPayResultSuccess) {
            resultTitle = @"支付成功";
        } else if (payResult == HLPayResultCancelled) {
            resultTitle = @"支付取消";
        } else {
            resultTitle = @"支付失败";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"⚠️" message:resultTitle delegate:weakSelf cancelButtonTitle:@"返回" otherButtonTitles:nil];
        [alertView show];

    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kHLPaymentInfoSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kHLPaymentInfoSectionPayConfig) {
        return 2;
    } else if (section == kHLPaymentInfoSectionPayPoints) {
        return self.payPoints.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLPayInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[HLPayInfoCell defaultReusebleIdentifier] forIndexPath:indexPath];
    if (indexPath.section == kHLPaymentInfoSectionPayConfig) {
        __block NSMutableString *content = [[NSMutableString alloc] init];
        HLPaymentConfigurationDetail *detail = nil;
        if (indexPath.row == 0) {
            [content appendString:@"AliPay\n"];
            detail = self.configuration.alipay;
        } else if (indexPath.row == 1) {
            [content appendString:@"WechatPay\n"];
            detail = self.configuration.weixin;
        }
        if (detail) {
            [[detail allProperties] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = [detail valueForKey:obj];
                if ([value isKindOfClass:[NSObject class]]) {
                    [content appendString:[NSString stringWithFormat:@"%@:%@\n",obj,value]];
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        [content appendString:[NSString stringWithFormat:@"%@:%@\n",obj,[value valueForKey:key]]];
                    }];
                }
            }];
        } else {
            [content appendString:@"null"];
        }
        cell.content = content;
    } else if (indexPath.section == kHLPaymentInfoSectionPayPoints) {
        if (indexPath.row < self.payPoints.count) {
            HLPayPoint *payPoint = self.payPoints[indexPath.row];
            __block NSMutableString *content = [[NSMutableString alloc] init];
            [[payPoint allProperties] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [content appendString:[NSString stringWithFormat:@"%@:%@\n",obj,[payPoint valueForKey:obj]]];
            }];
            cell.content = content;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    if (section == kHLPaymentInfoSectionPayConfig) {
        label.text = @"PayConfiguration";
    } else if (section == kHLPaymentInfoSectionPayPoints) {
        label.text = @"PayPoints";
    }
    label.backgroundColor = [UIColor grayColor];
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kHLPaymentInfoSectionPayConfig) {
        if (!_payPoint) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"⚠️" message:@"没有选择计费点(PayPoints)将会使用默认信息支付" delegate:self cancelButtonTitle:@"返回选择计费点" otherButtonTitles:@"仍然去支付", nil];
            [alertView show];
        } else {
            [self pay:self.payPoint];
        }

    } else if (indexPath.section == kHLPaymentInfoSectionPayPoints) {
        if (indexPath.row < self.payPoints.count) {
            HLPayPoint *payPoint = self.payPoints[indexPath.row];
            self.payPoint = payPoint;
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        [self pay:nil];
    }
}

@end
