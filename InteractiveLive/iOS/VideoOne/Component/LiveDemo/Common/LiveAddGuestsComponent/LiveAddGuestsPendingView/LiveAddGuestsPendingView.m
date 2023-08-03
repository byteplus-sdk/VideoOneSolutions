// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsPendingView.h"

@interface LiveAddGuestsPendingView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) BaseButton *cancelButton;

@end


@implementation LiveAddGuestsPendingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskAction)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(219 + [DeviceInforTool getVirtualHomeHeight]);
        }];
        
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(16);
            make.size.mas_equalTo(CGSizeMake(90, 90));
        }];
        
        [self.contentView addSubview:self.describeLabel];
        [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(8);
            make.left.mas_equalTo(78);
            make.right.mas_equalTo(-78);
        }];
        
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.imageView.mas_bottom).offset(64);
            make.height.mas_equalTo(1);
        }];
        
        [self.contentView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.lineView.mas_bottom);
            make.height.mas_equalTo(48);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.contentView.bounds;
    layer.path = path.CGPath;
    self.contentView.layer.mask = layer;
}

#pragma mark - Private Action

- (void)cancelButtonAction {
    if (self.clickCancelBlock) {
        self.clickCancelBlock(YES);
    }
}

- (void)maskAction {
    if (self.clickCancelBlock) {
        self.clickCancelBlock(NO);
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromHexString:@"#161823"];
    }
    return _contentView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"guests_pending" bundleName:HomeBundleName];
    }
    return _imageView;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.textColor = [UIColor colorFromHexString:@"#CCCED0"];
        _describeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _describeLabel.numberOfLines = 2;
        _describeLabel.textAlignment = NSTextAlignmentCenter;
        _describeLabel.text = @"The co-host request has been sent.\nPlease be patient.";
    }
    return _describeLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
    }
    return _lineView;
}

- (BaseButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[BaseButton alloc] init];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_cancelButton setTitle:LocalizedString(@"cancel") forState:UIControlStateNormal];
    }
    return _cancelButton;
}


@end
