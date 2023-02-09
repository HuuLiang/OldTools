//
//  HLPayPoint.h
//  HLPayment
//
//  Created by Liang on 2018/4/20.
//

#import <Foundation/Foundation.h>

@interface HLPayPoint : NSObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *payPointType;
@property (nonatomic) NSNumber *fee;
@property (nonatomic) NSString *pointRecommend;
@property (nonatomic) NSString *descInfo;
@property (nonatomic) NSNumber *validMonths;
@property (nonatomic) NSNumber *validResources;

@end

typedef NSDictionary<NSString *, NSArray<HLPayPoint *> *> HLPayPoints;
