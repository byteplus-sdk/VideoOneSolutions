// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveHostMediaView.h"

@interface LiveHostMediaView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation LiveHostMediaView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];

        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(50);
        }];

        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(self.titleLabel);
        }];

        NSMutableArray *buttonList = [[NSMutableArray alloc] init];
        NSInteger buttonNumber = 4;
        for (int i = 0; i < buttonNumber; i++) {
            BaseButton *button = [[BaseButton alloc] init];
            button.tag = 3000 + i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            UIImage *image = [UIImage imageNamed:[self getImageName:i] bundleName:HomeBundleName];
            [button setImage:image forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
            [self addSubview:button];
            [self addMessage:button row:i];
            [buttonList addObject:button];
        }
        [buttonList mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:70 leadSpacing:10 tailSpacing:10];
        [buttonList mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineView.mas_bottom).offset(20);
            make.height.mas_equalTo(32);
        }];
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

#pragma mark - Publish Action

- (void)updateButtonStatus:(LiveHostMediaStatus)status
                   isStart:(BOOL)isStart {
    NSInteger row = status;
    BOOL isSelect = !isStart;
    BaseButton *button = [self viewWithTag:3000 + row];
    NSString *imageName = isSelect ? [self getSelectImageName:row] : [self getImageName:row];
    NSString *titleString = isSelect ? [self getSelectMessage:row] : [self getMessage:row];

    if (NOEmptyStr(imageName)) {
        UIImage *image = [UIImage imageNamed:imageName
                                  bundleName:HomeBundleName];
        [button setImage:image forState:UIControlStateNormal];
    }
    if (NOEmptyStr(titleString)) {
        UILabel *label = [button viewWithTag:4000];
        label.text = titleString;
    }
    button.selected = isSelect;
}

- (void)updateFlipImage:(LiveHostMediaStatus)status currentFlipImage:(BOOL)currentFlipImage {
    NSInteger row = status;
    BaseButton *button = [self viewWithTag:3000 + row];
    if (currentFlipImage) {
        UIImage *image = [UIImage imageNamed:@"live_switch_camera"
                                  bundleName:HomeBundleName];
        [button setImage:image forState:UIControlStateNormal];
    } else {
        UIImage *image = [UIImage imageNamed:@"live_switch_camera_before"
                                  bundleName:HomeBundleName];
        [button setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - Private Action

- (void)buttonAction:(UIButton *)sender {
    NSInteger row = sender.tag - 3000;

    if ([self.delegate respondsToSelector:@selector(hostMediaView:clickButton:isStart:)]) {
        [self.delegate hostMediaView:self clickButton:row
                             isStart:!sender.selected];
    }
}

- (void)addMessage:(UIButton *)sender row:(NSInteger)row {
    sender.clipsToBounds = NO;
    UILabel *label = [[UILabel alloc] init];
    label.tag = 4000;
    label.text = [self getMessage:row];
    label.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [sender addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sender);
        make.top.equalTo(sender.mas_bottom).offset(4);
        make.height.mas_equalTo(16);
    }];
}

- (NSString *)getMessage:(NSInteger)row {
    NSString *message = @"";
    switch (row) {
        case 0:
            message = LocalizedString(@"flip");
            break;
        case 1:
            message = LocalizedString(@"microphone");
            break;
        case 2:
            message = LocalizedString(@"camera");
            break;
        case 3:
            message = LocalizedString(@"Info");
            break;
        default:
            break;
    }
    return message;
}

- (NSString *)getSelectMessage:(NSInteger)row {
    NSString *message = @"";
    switch (row) {
        case 0:

            break;
        case 1:
            message = LocalizedString(@"mute");
            break;
        case 2:
            message = LocalizedString(@"camera_off");
            break;
        case 3:

            break;

        default:
            break;
    }
    return message;
}

- (NSString *)getImageName:(NSInteger)row {
    NSString *imageName = @"";
    switch (row) {
        case 0:
            imageName = @"live_switch_camera_before";
            break;
        case 1:
            imageName = @"more_mic";
            break;
        case 2:
            imageName = @"more_camera";
            break;
        case 3:
            imageName = @"more_info_icon";
            break;
        default:
            break;
    }
    return imageName;
}

- (NSString *)getSelectImageName:(NSInteger)row {
    NSString *imageName = @"";
    switch (row) {
        case 0:
            break;
        case 1:
            imageName = @"more_mic_select";
            break;
        case 2:
            imageName = @"more_camera_select";
            break;
        case 3:
            break;
        default:
            break;
    }
    return imageName;
}

#pragma mark - Getter

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _titleLabel.text = LocalizedString(@"more");
    }
    return _titleLabel;
}

@end
