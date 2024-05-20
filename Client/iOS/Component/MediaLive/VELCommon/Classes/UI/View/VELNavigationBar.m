// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELNavigationBar.h"
#import "VELCommonDefine.h"
#import "UIControl+VELAdd.h"
#import <Masonry/Masonry.h>
@interface VELNavigationBar ()
@property (nonatomic, strong, readwrite) VELUIButton *leftButton;
@property (nonatomic, strong, readwrite) VELUIButton *rightButton;
@property (nonatomic, strong, readwrite) VELUILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIView *wrapperView;
@end

@implementation VELNavigationBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

+ (instancetype)navigationBarWithTitle:(NSString *)title {
    VELNavigationBar *view = [[VELNavigationBar alloc] init];
    view.titleLabel.text = title;
    return view;
}

- (void)onlyShowTitle {
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
}

- (void)onlyShowLeftBtn {
    self.leftButton.hidden = NO;
    self.titleLabel.hidden = YES;
    self.rightButton.hidden = YES;
}
- (void)setupUI {
    self.topSafeMargin = [VELDeviceHelper statusBarHeight];
    [self onlyShowTitle];
    self.backgroundColor = [UIColor whiteColor];
    UIView *wrapView = [[UIView alloc] init];
    self.wrapperView = wrapView;
    [self addSubview:wrapView];
    [wrapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self).mas_offset(self.topSafeMargin);
    }];

    [wrapView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.centerY.equalTo(wrapView);
        make.width.height.equalTo(@(20));
    }];

    [wrapView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton);
        make.centerX.mas_equalTo(0);
    }];
    
    [wrapView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton);
        make.width.height.equalTo(@20);
        make.right.mas_equalTo(-18);
    }];
    [wrapView addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(wrapView);
        make.height.mas_equalTo(0.5);
    }];
    self.rightButton.hidden = YES;
}
- (void)setTopSafeMargin:(CGFloat)topSafeMargin {
    _topSafeMargin = topSafeMargin;
    [self.wrapperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(topSafeMargin);
    }];
}
- (VELUIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[VELUIButton alloc] init];
        _leftButton.imageSize = CGSizeMake(18, 18);
        [_leftButton setImage:VELUIImageMake(@"ic_arrow_left_black") forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.hitEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    }
    return _leftButton;
}

- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = VELColorWithHex(0x1D2129);
    }
    return _titleLabel;
}

- (VELUIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[VELUIButton alloc] init];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightButton setContentMode:UIViewContentModeCenter];
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.hitEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    }
    return _rightButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.hidden = YES;
        _bottomLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    }
    return _bottomLine;
}
- (void)leftButtonAction:(id)sender {
    if (self.leftEventBlock) {
        self.leftEventBlock();
    }
}

- (void)rightButtonAction:(id)sender {
    if (self.rightEventBlock) {
        self.rightEventBlock();
    }
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}
@end
