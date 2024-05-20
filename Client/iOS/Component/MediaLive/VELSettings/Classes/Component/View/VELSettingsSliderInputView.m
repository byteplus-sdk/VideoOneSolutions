// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSliderInputView.h"
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>
@interface VELSettingsSliderInputView () <VELUISliderDelegate, UITextFieldDelegate>
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VELUILabel *leftLabel;
@property (nonatomic, strong) VELUISlider *sliderView;
@property (nonatomic, strong) VELUILabel *rightLabel;
@property (nonatomic, strong) UIView *contentRightView;
@property (nonatomic, strong) UIView *contentLeftView;
@property (nonatomic, strong) UITextField *inputField;
@end
@implementation VELSettingsSliderInputView

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    self.contentView = [[UIView alloc] init];
    [container addSubview:self.contentView];
    self.contentLeftView = [[UIView alloc] init];
    [self.contentView addSubview:self.contentLeftView];
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.sliderView];
    [self.contentView addSubview:self.inputField];
    [self.contentView addSubview:self.rightLabel];
    self.contentRightView = [[UIView alloc] init];
    [self.contentView addSubview:self.contentRightView];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    
    self.titleLabel.hidden = VEL_IS_EMPTY_STRING(self.model.title);
    if (VEL_IS_EMPTY_STRING(self.model.title)) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container);
        }];
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.container).mas_offset(self.model.insets);
        }];
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(self.model.insets.top);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        }];
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(self.model.spaceBetweenTitleAndField);
            make.left.equalTo(self.container).mas_offset(self.model.insets.left);
            make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
            make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
        }];
    }
    
    UIView *leftView = self.contentLeftView;
    [self.contentLeftView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(0.01);
    }];
    
    self.leftLabel.hidden = VEL_IS_EMPTY_STRING(self.model.leftText);
    
    if (VEL_IS_EMPTY_STRING(self.model.leftText)) {
        [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    } else {
        [self.leftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self.contentView);
        }];
        leftView = self.leftLabel;
    }
    self.sliderView.hidden = self.model.hideSlider;
    if (!self.model.hideSlider) {
        [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView.mas_right);
            make.top.bottom.equalTo(self.contentView);
            if (self.model.containerSize.height < 0) {
                make.height.mas_equalTo(50);
            }
        }];
        leftView = self.sliderView;
    } else {
        [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1, 1));
        }];
    }
    
    self.inputField.hidden = !self.model.showInput;
    if (self.model.showInput) {
        [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView.mas_right).mas_offset(self.model.inputOutset.left);
            make.top.equalTo(self.contentView).mas_offset(self.model.inputOutset.top);
            if (self.model.inputSize.width > 0) {
                make.width.mas_equalTo(self.model.inputSize.width);
            } else {
                make.width.mas_equalTo(58);
            }
            if (self.model.inputSize.height > 0) {
                make.height.mas_equalTo(self.model.inputSize.height);
            }
        }];
        leftView = self.inputField;
    } else {
        [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    
    self.rightLabel.hidden = VEL_IS_EMPTY_STRING(self.model.rightText);
    if (VEL_IS_EMPTY_STRING(self.model.rightText)) {
        [self.rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    } else {
        [self.rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            if (self.model.showInput) {
                make.left.equalTo(leftView.mas_right).mas_offset(self.model.inputOutset.right);
            } else {
                make.left.equalTo(leftView.mas_right).mas_offset(8);
            }
        }];
        leftView = self.rightLabel;
    }
    self.contentRightView.alpha = 0;
    [self.contentRightView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right);
        make.top.bottom.right.equalTo(self.contentView);
        make.width.mas_equalTo(0.01);
    }];
}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    
    self.titleLabel.textAttributes = self.model.titleAttribute;
    self.titleLabel.text = self.model.title;
    
    
    self.leftLabel.textAttributes = self.model.textAttribute;
    self.leftLabel.text = self.model.leftText;
    
    self.sliderView.minValue = self.model.minimumValue;
    self.sliderView.maxValue = self.model.maximumValue;
    self.sliderView.value = self.model.value;
    self.sliderView.activeLineColor = self.model.minimumTrackColor;
    self.sliderView.inactiveLineColor = self.model.maximumTrackColor;
    self.sliderView.enable = self.model.enable;
    if (self.model.enable) {
        self.sliderView.circleColor = self.model.thumbColor;
    } else {
        self.sliderView.circleColor = self.model.disableThumbColor;
    }
    self.sliderView.textColor = [UIColor whiteColor];
    
    self.sliderView.hidden = self.model.hideSlider;
    
    self.inputField.text = @(self.model.value).stringValue;
    self.inputField.backgroundColor = self.model.inputBgColor;
    self.inputField.defaultTextAttributes = self.model.inputTextAttribute;
    
    self.rightLabel.textAttributes = self.model.textAttribute;
    self.rightLabel.text = self.model.rightText;
    
}

- (void)progressDidChange:(VELUISlider *)sender progress:(CGFloat)progress {
    self.model.value = progress;
    if ([self.model.valueFormat containsString:@"f"]) {
        self.inputField.text = [NSString stringWithFormat:self.model.valueFormat, progress];
    } else {
        self.inputField.text = [NSString stringWithFormat:self.model.valueFormat, (int)progress];
    }
    if (self.model.valueChangedBlock) {
        self.model.valueChangedBlock(self.model);
    }
}

- (void)progressEndChange:(VELUISlider *)sender progress:(CGFloat)progress {
    
}

- (BOOL)isPureIntegerValue:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
- (BOOL)checkTextFieldTextIsValid:(NSString *)text notify:(BOOL)notify {
    NSString *result = text;
    NSScanner *scan = [NSScanner scannerWithString:result];
    NSInteger value;
    BOOL isPureInt = [scan scanInteger:&value] && [scan isAtEnd];
    UIView *tipView = UIApplication.sharedApplication.keyWindow;
    if (!isPureInt) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_input_invalid", @"MediaLive") inView:tipView];
        self.inputField.text = @(self.model.value).stringValue;
        return NO;
    }
    if (self.model.minimumValue != self.model.maximumValue) {
        if (value < self.model.minimumValue) {
            NSString *tip = [NSString stringWithFormat:@"%@ %@", LocalizedStringFromBundle(@"medialive_input_value_less_than", @"MediaLive"),@(self.model.minimumValue)];
            [VELUIToast showText:tip inView:tipView];
            self.inputField.text = @(self.model.value).stringValue;
            return NO;
        }
        if (value > self.model.maximumValue) {
            NSString *tip = [NSString stringWithFormat:@"%@ %@", LocalizedStringFromBundle(@"medialive_input_value_greater_than", @"MediaLive"),@(self.model.maximumValue)];
            [VELUIToast showText:tip inView:tipView];
            self.inputField.text = @(self.model.value).stringValue;
            return NO;
        }
    }
    self.model.value = value;
    self.sliderView.value = value;
    if (!notify) {
        return YES;
    }
    if (self.model.valueChangedBlock) {
        self.model.valueChangedBlock(self.model);
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self checkTextFieldTextIsValid:textField.text notify:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.tintColor = UIColor.clearColor;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        UITextPosition *position = [textField endOfDocument];
        [textField setSelectedTextRange:[textField textRangeFromPosition:position toPosition:position]];
        textField.tintColor = nil;
    }];
    [CATransaction commit];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self checkTextFieldTextIsValid:textField.text notify:NO]) {
        return YES;
    }
    return NO;
}
- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (VELUILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[VELUILabel alloc] init];
        _leftLabel.hidden = YES;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

- (VELUISlider *)sliderView {
    if (!_sliderView) {
        _sliderView = [[VELUISlider alloc] init];
        _sliderView.delegate = self;
        _sliderView.paddingLeft = 6;
        _sliderView.paddingRight = 6;
        _sliderView.sliderType = VELTextSliderTypeNormal;
        _sliderView.backgroundColor = UIColor.clearColor;
        _sliderView.progressFunc = ^NSString *(CGFloat progress) {
            return @"";
        };
    }
    return _sliderView;
}

- (VELUILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[VELUILabel alloc] init];
        _rightLabel.hidden = YES;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        [_rightLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
    }
    return _rightLabel;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] init];
        _inputField.delegate = self;
        _inputField.textAlignment = NSTextAlignmentCenter;
        _inputField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
        _inputField.leftViewMode = UITextFieldViewModeAlways;
        _inputField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
        _inputField.rightViewMode = UITextFieldViewModeAlways;
        _inputField.layer.cornerRadius = 3;
        _inputField.clipsToBounds = YES;
        _inputField.hidden = YES;
        _inputField.keyboardType = UIKeyboardTypeNumberPad;
        _inputField.returnKeyType = UIReturnKeyDone;
    }
    return _inputField;
}
@end
