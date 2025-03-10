// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SelectableButton.h"
#import "RectangleSelectableView.h"
#import "LightUpSelectableView.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"

@interface SelectableButton ()

@property (nonatomic, strong) BaseSelectableView *sv;
@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, strong) UIImageView *ivPoint;

@property (nonatomic, weak) UITapGestureRecognizer *tapRecognizer;

@end

@implementation SelectableButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        
        [self addSubview:self.lTitle];
        [self addSubview:self.ivPoint];
    }
    return self;
}

- (instancetype)initWithSelectableConfig:(id<SelectableConfig>)config {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        _selectableConfig = config;
        
        [self addSubview:self.lTitle];
        [self addSubview:self.ivPoint];
        
        [self setSelectableConfig:config];
    }
    return self;
}
- (UIView *)contentView {
    return self.sv;
}
#pragma mark - public
- (void)setSelectableConfig:(id<SelectableConfig>)selectableConfig {
    _selectableConfig = selectableConfig;
    
    if (_sv) {
        [_sv removeFromSuperview];
    }
    
    _sv = [selectableConfig generateView];
    [self addSubview:_sv];
    [_sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(selectableConfig.imageSize);
        make.top.equalTo(self);
    }];
    
    if ([selectableConfig class] == [LightUpSelectableConfig class]) {
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.mas_equalTo((60));
            make.top.equalTo(self.sv.mas_bottom).offset((4));
        }];
    }
    else if ([selectableConfig class] == [RectangleSelectableConfig class]){
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.mas_equalTo((60));
            make.top.equalTo(self.sv.mas_bottom).offset((1));
        }];
    }
    else{
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.mas_equalTo((60));
            make.top.equalTo(self.sv.mas_bottom).offset((4));
        }];
    }
    
    
    [self.ivPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(3, 3));
        make.top.equalTo(self.lTitle.mas_bottom).offset((2));
    }];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    self.sv.isSelected = isSelected;
    if (isSelected) {
        self.lTitle.alpha = 1.f;
    } else {
        self.lTitle.alpha = 0.55f;
    }
}

- (void)setIsPointOn:(BOOL)isPointOn {
    _isPointOn = isPointOn;
    
    self.ivPoint.hidden = !isPointOn;
}

- (void)setTitle:(NSString *)title {
//    self.lTitle.text = title;
    if (title == nil) {
        _lTitle.text = nil;
        _lTitle.attributedText = nil;
        return;
    }
    NSMutableAttributedString * attributedStringM = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle * paragraphStyleM = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleM setLineSpacing:0];
    paragraphStyleM.maximumLineHeight = 14;
    paragraphStyleM.minimumLineHeight = 14;
    paragraphStyleM.alignment = NSTextAlignmentCenter;
    paragraphStyleM.lineBreakMode = _lTitle.lineBreakMode;
    [attributedStringM addAttribute:NSParagraphStyleAttributeName value:paragraphStyleM range:NSMakeRange(0, [title length])];
    [_lTitle setAttributedText:attributedStringM];
    [_lTitle sizeToFit];
}

- (void)setDelegate:(id<SelectableButtonDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate) {
        UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectableButtonDidTap:)];
        [self addGestureRecognizer:rec];
        self.tapRecognizer = rec;
    } else {
        [self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
    }
}

#pragma mark - action
- (void)selectableButtonDidTap:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectableButton:didTap:)]) {
        [self.delegate selectableButton:self didTap:sender];
    }
}

#pragma mark - getter
- (BaseSelectableView *)sv {
    if (_sv) {
        return _sv;
    }
    
    _sv = [_selectableConfig generateView];
    return _sv;
}

- (UILabel *)lTitle {
    if (_lTitle) {
        return _lTitle;
    }
    
    _lTitle = [UILabel new];
    _lTitle.font = [UIFont systemFontOfSize:11];
    _lTitle.numberOfLines = 2;
    _lTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _lTitle.textAlignment = NSTextAlignmentCenter;
    _lTitle.textColor = [UIColor whiteColor];
    return _lTitle;
}

- (UIImageView *)ivPoint {
    if (_ivPoint) {
        return _ivPoint;
    }
    
    _ivPoint = [[UIImageView alloc] init];
    _ivPoint.image = [EffectCommon imageNamed:@"ic_point"];
    _ivPoint.hidden = YES;
    return _ivPoint;
}

@end
