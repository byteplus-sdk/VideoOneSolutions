// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfoItemView.h"

@interface LiveInfoItemView  ()

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* valueLabel;

@end

@implementation LiveInfoItemView

- (instancetype)init {
    self = [super init];
    if(self) {
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self);
            make.height.mas_equalTo(16);
        }];
        [self addSubview:self.valueLabel];
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self);
            make.height.mas_equalTo(28);
        }];
    }
    return  self;
}


- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setValue:(NSNumber *)value {
    if(value) {
        _value = value;
        self.valueLabel.text =  [self transformNumber:value];
    } else {
        _value = [NSNumber numberWithInt:0];
        self.valueLabel.text = @"0";
    }
}

- (NSString *)transformNumber:(NSNumber *)value {
    NSNumber *thousand = [NSNumber numberWithInt:1000];
    NSNumber *million = [NSNumber numberWithInt:100000];
    NSComparisonResult r1 = [value compare:thousand];
    NSComparisonResult r2 = [value compare:million];
    NSString *result = nil;
    if(r1 == NSOrderedAscending) {
        result = [value stringValue];
    } else {
        if(r2 == NSOrderedAscending) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.positiveFormat = @",###";
            result = [formatter stringFromNumber:value];
        } else {
            float header = value.floatValue / 1000;
            NSNumber *realValue = [NSNumber numberWithFloat:header];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            formatter.positiveFormat = @",###.#";
            result = [NSString stringWithFormat:@"%@%@",[formatter stringFromNumber:realValue],@"K"];
        }
    }
    return  result;
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel =  [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.5*255];
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return  _titleLabel;
}

- (UILabel *)valueLabel {
    if(!_valueLabel) {
        _valueLabel =  [[UILabel alloc] init];
        _valueLabel.textColor =  [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9*255];
        _valueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    }
    return _valueLabel;
}

@end
