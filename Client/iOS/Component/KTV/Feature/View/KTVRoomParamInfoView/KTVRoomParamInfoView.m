//
//  KTVRoomParamInfoView.m
//  veRTC_Demo
//
//  Created by on 2021/4/9.
//  
//

#import "KTVRoomParamInfoView.h"
#import "UIView+Fillet.h"

@interface KTVRoomParamInfoView ()

@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *valueView;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation KTVRoomParamInfoView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.messageView];
        [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@0);
            make.width.equalTo(@34);
            make.height.equalTo(@20);
        }];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.messageView);
        }];
        
        [self addSubview:self.valueView];
        [self addSubview:self.valueLabel];
        [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageView.mas_right).offset(6);
            make.centerY.equalTo(self);
        }];
        
        [self.valueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.messageView);
            make.height.equalTo(@20);
            make.right.equalTo(self.valueLabel).offset(6);
        }];
        
        [self layoutIfNeeded];
        [self.messageView filletWithRadius:4 corner:UIRectCornerBottomLeft | UIRectCornerTopLeft];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.valueView filletWithRadius:4 corner:UIRectCornerBottomRight | UIRectCornerTopRight];
}

#pragma mark - Publish Action


- (void)setParamInfoModel:(KTVRoomParamInfoModel *)paramInfoModel {
    _paramInfoModel = paramInfoModel;
    
    if (IsEmptyStr(paramInfoModel.rtt)) {
        paramInfoModel.rtt = @"0";
    }
    self.messageLabel.text = LocalizedString(@"label_rtt_title");
    self.valueLabel.text = [NSString stringWithFormat:LocalizedString(@"label_rtt_value_%@"),
                            paramInfoModel.rtt];
    self.messageView.hidden = NO;
    self.valueView.hidden = NO;
    
    [self layoutIfNeeded];
}

#pragma mark - Private Action

- (UIView *)valueView {
    if (!_valueView) {
        _valueView = [[UIView alloc] init];
        _valueView.backgroundColor = [UIColor colorFromRGBHexString:@"#42464E" andAlpha:0.4 * 255];
        _valueView.hidden = YES;
    }
    return _valueView;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _valueLabel.textColor = [UIColor colorFromHexString:@"#C7CCD6"];
    }
    return _valueLabel;
}

- (UIView *)messageView {
    if (!_messageView) {
        _messageView = [[UIView alloc] init];
        _messageView.backgroundColor = [UIColor colorFromRGBHexString:@"#1C5E35" andAlpha:0.2 * 255];
        _messageView.hidden = YES;
    }
    return _messageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#9DA3AF"];
    }
    return _messageLabel;
}

@end
