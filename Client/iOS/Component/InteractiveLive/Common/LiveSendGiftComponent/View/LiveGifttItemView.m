// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftItemView.h"

@interface LiveGiftItemView ()

@property (nonatomic, strong) UIImageView *giftImage;

@property (nonatomic, strong) UILabel *giftName;

@property (nonatomic, assign) GiftType giftType;

@property (nonatomic, copy) void (^onClick)(GiftType);

@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation LiveGiftItemView

- (instancetype)initWithBlock:(void (^)(GiftType))onClick {
    self = [super init];
    if (self) {
        self.onClick = onClick;
        [self addSubview:self.giftImage];
        [self.giftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.top.mas_equalTo(self).offset(16);
            make.centerX.mas_equalTo(self);
        }];
        [self setNeedsLayout];
        [self addSubview:self.giftName];
        [self.giftName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.giftImage.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(16);
        }];
        [self addSubview:self.sendButton];
        [self.sendButton
                   addTarget:self
                      action:@selector(onSendButtonAction)
            forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(24);
            make.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *path = [UIBezierPath
        bezierPathWithRoundedRect:self.bounds
                byRoundingCorners:UIRectCornerAllCorners
                      cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

#pragma mark - Public Action

- (void)setModel:(LiveGiftModel *)model {
    _model = model;
    self.giftName.text = model.giftName;
    UIImage *giftImage = [UIImage imageNamed:model.giftIcon bundleName:HomeBundleName];
    self.giftImage.image = giftImage;
    self.giftType = model.giftType;
}

- (void)beSelected:(BOOL)isSelect {
    self.giftName.hidden = isSelect;
    self.sendButton.hidden = !isSelect;
    if (isSelect) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#1F1F1F"];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.onClick) {
        self.onClick(self.giftType);
    }
}

#pragma mark - Private Action

- (void)onSendButtonAction {
    if ([self.delegate respondsToSelector:@selector(liveGiftItemSendButtonHandler:)]) {
        [self.delegate liveGiftItemSendButtonHandler:self.giftType];
    }
}

#pragma mark - Getter

- (UIImageView *)giftImage {
    if (!_giftImage) {
        _giftImage = [[UIImageView alloc] init];
        _giftImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftImage;
}

- (UILabel *)giftName {
    if (!_giftName) {
        _giftName = [[UILabel alloc] init];
        _giftName.textAlignment = NSTextAlignmentCenter;
        _giftName.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
        _giftName.font = [UIFont systemFontOfSize:12];
    }
    return _giftName;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        UILabel *label = [[UILabel alloc] init];
        CAGradientLayer *layer = [[CAGradientLayer layer] init];
        layer.colors = @[
            (__bridge id)[UIColor colorFromRGBHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromRGBHexString:@"#ED3596"].CGColor
        ];
        layer.frame = CGRectMake(0, 0, 75, 24);
        layer.startPoint = CGPointMake(0, 1);
        layer.endPoint = CGPointMake(1, 0);
        [_sendButton.layer addSublayer:layer];

        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF"];
        label.font = [UIFont systemFontOfSize:12 weight:500];
        label.text = LocalizedString(@"gift_send_button_text");
        [_sendButton addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_sendButton);
        }];
        _sendButton.hidden = YES;
    }
    return _sendButton;
}

@end
