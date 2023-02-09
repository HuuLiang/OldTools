//
//  HLPayInfoCell.m
//  HLPayment_Example
//
//  Created by Liang on 2018/4/21.
//  Copyright © 2018年 757437150@qq.com. All rights reserved.
//

#import "HLPayInfoCell.h"

#import <Masonry.h>

@interface HLPayInfoCell ()
@property (nonatomic,strong) UILabel *contentLabel;
@end

@implementation HLPayInfoCell

+ (NSString *)defaultReusebleIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setContent:(NSString *)content {
    self.contentLabel.text = content;
}

- (UILabel *)contentLabel {
    if (_contentLabel) {
        return _contentLabel;
    }
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor blueColor];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont systemFontOfSize:10];
    _contentLabel.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_contentLabel];
    {
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _contentLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
