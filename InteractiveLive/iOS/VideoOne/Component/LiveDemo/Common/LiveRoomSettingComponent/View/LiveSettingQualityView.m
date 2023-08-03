// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingQualityView.h"

@interface LiveSettingQualityView ()

@property (nonatomic, strong) NSArray *resList;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) BaseButton *backButton;

@end

@implementation LiveSettingQualityView

- (instancetype)initWithKey:(NSString *)key {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"];
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(16);
        }];
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(16);
            make.height.mas_equalTo(1);
        }];
        
        [self addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.centerY.equalTo(self.titleLabel);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        for (int i = 0; i < self.resList.count; i++) {
            NSString *message = self.resList[i];
            BaseButton *button = [[BaseButton alloc] init];
            UIColor *color = [UIColor colorFromHexString:@"#FFFFFF"];
            [button setTitleColor:color forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
            [button setTitle:message forState:UIControlStateNormal];
            [button addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.buttons addObject:button];
        }
        
        [self.buttons mas_distributeViewsAlongAxis:MASAxisTypeVertical
                               withFixedItemLength:52
                                       leadSpacing:52
                                       tailSpacing:[DeviceInforTool getVirtualHomeHeight] + 52];
        [self.buttons mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIButton *hdButton = self.buttons[0];
            [hdButton setImage:[UIImage imageNamed:@"setting_hd" bundleName:HomeBundleName] forState:UIControlStateNormal];
            [hdButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -(hdButton.imageView.size.width + 2), 0, (hdButton.imageView.size.width + 2))];
            [hdButton setImageEdgeInsets:UIEdgeInsetsMake(-2, hdButton.titleLabel.bounds.size.width, 2, -hdButton.titleLabel.bounds.size.width)];
        });
        
        
        UIButton *selectButton = nil;
        for (UIButton *tempButton in self.buttons) {
            if ([tempButton.titleLabel.text isEqualToString:key]) {
                selectButton = tempButton;
                break;
            }
        }
        if (selectButton) {
            selectButton.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.06 * 255];
            [selectButton setTitleColor:[UIColor colorFromRGBHexString:@"#FF1764" andAlpha:1.0 * 255] forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (void)itemButtonClicked:(UIButton *)sender {
    if (self.clickItemBlock) {
        self.clickItemBlock(sender.titleLabel.text);
    }
    [self backButtonAction];
}

- (void)backButtonAction {
    if (self.clickBackBlock) {
        self.clickBackBlock();
    }
}

#pragma mark - Getter

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[BaseButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"nav_left" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [[NSMutableArray alloc] init];
    }
    return _buttons;
}

- (NSArray *)resList {
    if (!_resList) {
        _resList = @[@"1080p", @"720p", @"540p"];
    }
    return _resList;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedString(@"quality");
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
