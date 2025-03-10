// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectMainTabCell.h"
#import "EffectScrollableLabel.h"
#import <Masonry/Masonry.h>

@interface EffectMainTabCell()

@property (nonatomic, strong) EffectScrollableLabel *titleLabel;

@end

@implementation EffectMainTabCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(16);
        }];
        
        _textScrollable = NO;
    }
    return self;
}

- (void)setTextScrollable:(BOOL)textScrollable {
    _textScrollable = textScrollable;
    
    self.titleLabel.scrollable = textScrollable;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    self.titleLabel.textColor = selected ? self.hightlightTextColor : self.normalTextColor;
}

-(void)renderWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setTitleLabelFont:(UIFont *)font{
    self.titleLabel.font = font;
}

- (void)setNormalTextColor:(UIColor *)normalTextColor {
    _normalTextColor = normalTextColor;
    
    if (!self.selected) {
        self.titleLabel.textColor = normalTextColor;
    }
}

- (void)setHightlightTextColor:(UIColor *)hightlightTextColor {
    _hightlightTextColor = hightlightTextColor;
    
    if (self.selected) {
        self.titleLabel.textColor = hightlightTextColor;
    }
}

#pragma mark - getter

- (EffectScrollableLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[EffectScrollableLabel alloc] init];
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.label.numberOfLines = 0;
//        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.scrollable = self.textScrollable;
    }
    return _titleLabel;
}

@end
