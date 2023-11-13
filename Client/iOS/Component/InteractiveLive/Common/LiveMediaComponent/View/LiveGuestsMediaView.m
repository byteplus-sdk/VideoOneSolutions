// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGuestsMediaView.h"

@interface LiveGuestsMediaView ()

@property (nonatomic, strong) BaseButton *cancelButton;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation LiveGuestsMediaView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorFromHexString:@"#161823"];

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
            [buttonList addObject:button];
            [self addMessage:button row:i];
        }
        [buttonList mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:52 leadSpacing:24 tailSpacing:24];
        [buttonList mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(24);
            make.height.mas_equalTo(52);
        }];

        CGFloat linePX = (1 / [UIScreen mainScreen].scale);
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(linePX);
            make.top.mas_equalTo(124);
        }];

        [self addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(self);
            make.height.mas_equalTo(48);
            make.top.equalTo(self.lineView.mas_bottom);
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

- (void)updateButtonStatus:(LiveGuestsMediaViewStatus)status
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

#pragma mark - Private Action

- (void)buttonAction:(UIButton *)sender {
    NSInteger row = sender.tag - 3000;

    if ([self.delegate respondsToSelector:@selector(guestsMediaView:clickButton:isStart:)]) {
        [self.delegate guestsMediaView:self clickButton:row isStart:!sender.selected];
    }
}

- (void)cancelButtonAction {
    if ([self.delegate respondsToSelector:@selector(guestsMediaView:clickButton:isStart:)]) {
        [self.delegate guestsMediaView:self clickButton:LiveGuestsMediaViewStatusCancel isStart:YES];
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
        make.top.equalTo(sender.mas_bottom).offset(8);
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
            message = LocalizedString(@"disconnect");
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
            imageName = @"more_flip_guest";
            break;
        case 1:
            imageName = @"more_mic_guest";
            break;
        case 2:
            imageName = @"more_camera_guest";
            break;
        case 3:
            imageName = @"more_dis_guest";
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
            imageName = @"more_mic_guest_select";
            break;
        case 2:
            imageName = @"more_camera_guest_select";
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
