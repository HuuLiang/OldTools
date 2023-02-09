//
//  HLPaymentInfo.m
//  HLPayment
//
//  Created by Liang on 2018/4/14.
//

#import "HLPaymentInfo.h"
#import "HLDefines.h"
#import "NSMutableDictionary+extend.h"
#import "NSString+extend.h"
#import "HLOrderInfo.h"
#import "HLContentInfo.h"
#import "HLPayPoint.h"
#import <NSObject+extend.h>


static NSString *const kPaymentInfoKeyName = @"hlpayment_paymentinfo_keyname";

static NSString *const kPaymentInfoPaymentIdKeyName = @"hlpayment_paymentinfo_paymentid_keyname";
static NSString *const kPaymentInfoOrderIdKeyName = @"hlpayment_paymentinfo_orderid_keyname";
static NSString *const kPaymentInfoOrderPriceKeyName = @"hlpayment_paymentinfo_orderprice_keyname";
static NSString *const kPaymentInfoOrderDescriptionKeyName = @"hlpayment_paymentinfo_orderdescription_keyname";
static NSString *const kPaymentInfoContentIdKeyName = @"hlpayment_paymentinfo_contentid_keyname";
static NSString *const kPaymentInfoContentTypeKeyName = @"hlpayment_paymentinfo_contenttype_keyname";
static NSString *const kPaymentInfoContentLocationKeyName = @"hlpayment_paymentinfo_contentlocation_keyname";
static NSString *const kPaymentInfoColumnIdKeyName = @"hlpayment_paymentinfo_columnid_keyname";
static NSString *const kPaymentInfoColumnTypeKeyName = @"hlpayment_paymentinfo_columntype_keyname";
static NSString *const kPaymentInfoPayPointTypeKeyName = @"hlpayment_paymentinfo_paypointtype_keyname";
static NSString *const kPaymentInfoCurrentPayPointTypeKeyName = @"hlpayment_paymentinfo_currentpaypointtype_keyname";
static NSString *const kPaymentInfoTargetPayPointTypeKeyName = @"hlpayment_paymentinfo_targetpaypointtype_keyname";
static NSString *const kPaymentInfoPluginTypeKeyName = @"hlpayment_paymentinfo_plugintype_keyname";
static NSString *const kPaymentInfoPaymentTypeKeyName = @"hlpayment_paymentinfo_paymenttype_keyname";
static NSString *const kPaymentInfoPaymentResultKeyName = @"hlpayment_paymentinfo_paymentresult_keyname";
static NSString *const kPaymentInfoPaymentStatusKeyName = @"hlpayment_paymentinfo_paymentstatus_keyname";
static NSString *const kPaymentInfoPaymentTimeKeyName = @"hlpayment_paymentinfo_paymenttime_keyname";
static NSString *const kPaymentInfoPaymentReservedDataKeyName = @"hlpayment_paymentinfo_paymentreserveddata_keyname";
static NSString *const kPaymentInfoPayPointKeyName = @"hlpayment_paymentinfo_paypoint_keyname";
static NSString *const kPaymentInfoUserIdKeyName = @"hlpayment_paymentinfo_userid_keyname";

static NSString *const kPaymentInfoVersionKeyName = @"hlpayment_paymentinfo_version_keyname";

@interface HLPaymentInfo ()
@property (nonatomic) NSString *paymentId;
@end


@implementation HLPaymentInfo

- (NSString *)paymentId {
    if (_paymentId) {
        return _paymentId;
    }
    
    _paymentId = [NSUUID UUID].UUIDString.md5;
    if (!_paymentId) {
        _paymentId = @([[NSDate date] timeIntervalSince1970]).stringValue.md5;
    }
    return _paymentId;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _paymentResult = HLPayResultUnknown;
        _paymentStatus = HLPayStatusUnknown;
        _version = @0.1;
    }
    return self;
}

- (instancetype)initWithOrderInfo:(HLOrderInfo *)orderInfo contentInfo:(HLContentInfo *)contentInfo {
    self = [self init];
    if (self) {
        
        _orderId = orderInfo.orderId;
        _orderPrice = orderInfo.orderPrice;
        _orderDescription = orderInfo.orderDescription;
        _paymentType = orderInfo.payType;
        _paymentTime = orderInfo.createTime;
        _reservedData = orderInfo.reservedData;
        _payPointType = orderInfo.targetPayPointType;
        _currentPayPointType = orderInfo.currentPayPointType;
        _targetPayPointType = orderInfo.targetPayPointType;
        _userId = orderInfo.userId;
        
        _contentId = contentInfo.contentId;
        _contentType = contentInfo.contentType;
        _contentLocation = contentInfo.contentLocation;
        _columnId = contentInfo.columnId;
        _columnType = contentInfo.columnType;
    }
    return self;
}

- (instancetype)initWithOrderInfo:(HLOrderInfo *)orderInfo contentInfo:(HLContentInfo *)contentInfo payPoint:(HLPayPoint *)payPoint {
    self = [self initWithOrderInfo:orderInfo contentInfo:contentInfo];
    if (self) {
        _payPoint = payPoint;
    }
    return self;
}

+ (instancetype)paymentInfoFromDictionary:(NSDictionary *)payment {
    HLPaymentInfo *paymentInfo = [[self alloc] init];
    paymentInfo.paymentId = payment[kPaymentInfoPaymentIdKeyName];
    paymentInfo.orderId = payment[kPaymentInfoOrderIdKeyName];
    paymentInfo.orderPrice = [payment[kPaymentInfoOrderPriceKeyName] unsignedIntegerValue];
    paymentInfo.orderDescription = payment[kPaymentInfoOrderDescriptionKeyName];
    paymentInfo.contentId = payment[kPaymentInfoContentIdKeyName];
    paymentInfo.contentType = payment[kPaymentInfoContentTypeKeyName];
    paymentInfo.contentLocation = payment[kPaymentInfoContentLocationKeyName];
    paymentInfo.columnId = payment[kPaymentInfoColumnIdKeyName];
    paymentInfo.columnType = payment[kPaymentInfoColumnTypeKeyName];
    paymentInfo.payPointType = [payment[kPaymentInfoPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.currentPayPointType = [payment[kPaymentInfoCurrentPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.targetPayPointType = [payment[kPaymentInfoTargetPayPointTypeKeyName] unsignedIntegerValue];
    paymentInfo.pluginType = [payment[kPaymentInfoPluginTypeKeyName] unsignedIntegerValue];
    paymentInfo.paymentType = [payment[kPaymentInfoPaymentTypeKeyName] unsignedIntegerValue];
    paymentInfo.paymentResult = [payment[kPaymentInfoPaymentResultKeyName] unsignedIntegerValue];
    paymentInfo.paymentStatus = [payment[kPaymentInfoPaymentStatusKeyName] unsignedIntegerValue];
    paymentInfo.paymentTime = payment[kPaymentInfoPaymentTimeKeyName];
    paymentInfo.reservedData = payment[kPaymentInfoPaymentReservedDataKeyName];
    paymentInfo.userId = payment[kPaymentInfoUserIdKeyName];
    paymentInfo.version = payment[kPaymentInfoVersionKeyName];
    paymentInfo.payPoint = [HLPayPoint objectFromDictionary:payment[kPaymentInfoPayPointKeyName]];
    return paymentInfo;
}

- (NSDictionary *)dictionaryFromCurrentPaymentInfo {
    NSMutableDictionary *payment = [NSMutableDictionary dictionary];
    [payment safelySetObject:self.paymentId forKey:kPaymentInfoPaymentIdKeyName];
    [payment safelySetObject:self.orderId forKey:kPaymentInfoOrderIdKeyName];
    [payment safelySetObject:@(self.orderPrice) forKey:kPaymentInfoOrderPriceKeyName];
    [payment safelySetObject:self.orderDescription forKey:kPaymentInfoOrderDescriptionKeyName];
    [payment safelySetObject:self.contentId forKey:kPaymentInfoContentIdKeyName];
    [payment safelySetObject:self.contentType forKey:kPaymentInfoContentTypeKeyName];
    [payment safelySetObject:self.contentLocation forKey:kPaymentInfoContentLocationKeyName];
    [payment safelySetObject:self.columnId forKey:kPaymentInfoColumnIdKeyName];
    [payment safelySetObject:self.columnType forKey:kPaymentInfoColumnTypeKeyName];
    [payment safelySetObject:@(self.payPointType) forKey:kPaymentInfoPayPointTypeKeyName];
    [payment safelySetObject:@(self.currentPayPointType) forKey:kPaymentInfoCurrentPayPointTypeKeyName];
    [payment safelySetObject:@(self.targetPayPointType) forKey:kPaymentInfoTargetPayPointTypeKeyName];
    [payment safelySetObject:@(self.pluginType) forKey:kPaymentInfoPluginTypeKeyName];
    [payment safelySetObject:@(self.paymentType) forKey:kPaymentInfoPaymentTypeKeyName];
    [payment safelySetObject:@(self.paymentResult) forKey:kPaymentInfoPaymentResultKeyName];
    [payment safelySetObject:@(self.paymentStatus) forKey:kPaymentInfoPaymentStatusKeyName];
    [payment safelySetObject:self.paymentTime forKey:kPaymentInfoPaymentTimeKeyName];
    [payment safelySetObject:self.reservedData forKey:kPaymentInfoPaymentReservedDataKeyName];
    [payment safelySetObject:self.userId forKey:kPaymentInfoUserIdKeyName];
    [payment safelySetObject:self.version forKey:kPaymentInfoVersionKeyName];
    [payment safelySetObject:[self.payPoint dictionaryRepresentation] forKey:kPaymentInfoPayPointKeyName];
    return payment;
}

+ (NSArray<HLPaymentInfo *> *)allPaymentInfos {
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HLPaymentInfo *paymentInfo = [HLPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos.count > 0 ? paymentInfos : nil;
}

- (void)save {
    NSArray *paymentInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfosM = [paymentInfos mutableCopy];
    if (!paymentInfosM) {
        paymentInfosM = [NSMutableArray array];
    }
    
    NSUInteger index = [paymentInfos indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *paymentId = ((NSDictionary *)obj)[kPaymentInfoPaymentIdKeyName];
        if ([paymentId isEqualToString:self.paymentId]) {
            return YES;
        }
        return NO;
    }];
    NSDictionary *payment = index != NSNotFound ? [paymentInfos objectAtIndex:index] : nil;
    
    if (payment) {
        [paymentInfosM removeObject:payment];
    }
    
    payment = [self dictionaryFromCurrentPaymentInfo];
    [paymentInfosM addObject:payment];
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentInfosM forKey:kPaymentInfoKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    HLLog(@"Save payment info: %@", payment);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryFromCurrentPaymentInfo]];
}
@end
