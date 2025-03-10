// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BubbleTipView.h"
#import <Masonry/Masonry.h>

@interface BubbleTipView ()

@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, strong) UILabel *lDesc;
@property (nonatomic, strong) UIView *vInterval;

@end

@implementation BubbleTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lTitle];
        [self addSubview:self.lDesc];
        [self addSubview:self.vInterval];
        
        [self.vInterval mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(10);
        }];
        
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.vInterval.mas_leading).offset(-8);
            make.centerY.equalTo(self);
            make.leading.greaterThanOrEqualTo(self);
        }];
        
        [self.lDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.vInterval.mas_trailing).offset(8);
            make.trailing.lessThanOrEqualTo(self);
            make.centerY.equalTo(self);
        }];
        
        _needReshow = YES;
    }
    return self;
}

- (void)update:(NSString *)title desc:(NSString *)desc {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:1];
    shadow.shadowBlurRadius = 2.f;
    shadow.shadowOffset = CGSizeMake(0, 0);
    if (title != nil) {
        NSAttributedString *attriTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSShadowAttributeName:shadow}];
        self.lTitle.attributedText = attriTitle;
    }
    if (desc != nil) {
        NSAttributedString *attriDesc = [[NSAttributedString alloc] initWithString:desc attributes:@{NSShadowAttributeName:shadow}];
        self.lDesc.attributedText = attriDesc;
    }
    
    if (desc == nil || [desc isEqual:@""]) {
        self.vInterval.hidden = YES;
        self.lDesc.hidden = YES;
        [self.lTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    } else {
        self.vInterval.hidden = NO;
        self.lDesc.hidden = NO;
        [self.lTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.vInterval.mas_leading).offset(-8);
            make.centerY.equalTo(self);
            make.leading.equalTo(self);
        }];
    }
}

- (void)setCompleteBlock:(dispatch_block_t)completeBlock {
    _completeBlock = completeBlock;
    _blockInvoked = NO;
}

#pragma mark - getter
- (UILabel *)lTitle {
    if (_lTitle) {
        return _lTitle;
    }
    
    _lTitle = [UILabel new];
    _lTitle.textColor = [UIColor whiteColor];
    _lTitle.font = [UIFont systemFontOfSize:15];
    _lTitle.adjustsFontSizeToFitWidth = YES;
    _lTitle.textAlignment = NSTextAlignmentRight;
    return _lTitle;
}

- (UILabel *)lDesc {
    if (_lDesc) {
        return _lDesc;
    }
    
    _lDesc = [UILabel new];
    _lDesc.textColor = [UIColor whiteColor];
    _lDesc.font = [UIFont systemFontOfSize:12];
    _lDesc.adjustsFontSizeToFitWidth = YES;
    return _lDesc;
}

- (UIView *)vInterval {
    if (_vInterval) {
        return _vInterval;
    }
    
    _vInterval = [UIView new];
    _vInterval.backgroundColor = [UIColor whiteColor];
    return _vInterval;
}

@end
