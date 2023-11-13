// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsApplyView.h"
#import <AVFoundation/AVFoundation.h>

@interface LiveAddGuestsApplyView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) BaseButton *applyButton;
@property (nonatomic, strong) BaseButton *cancelButton;

@end

@implementation LiveAddGuestsApplyView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskAction)];
        [self addGestureRecognizer:tap];

        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(108 + [DeviceInforTool getVirtualHomeHeight]);
        }];

        [self.contentView addSubview:self.applyButton];
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.mas_equalTo(52);
        }];

        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.applyButton.mas_bottom);
            make.height.mas_equalTo(8);
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

#pragma mark - Publish Action

- (void)setUserModel:(LiveUserModel *)userModel {
    _userModel = userModel;

    if (userModel.status == LiveInteractStatusApplying) {
        // Inviting
        self.applyButton.alpha = 0.34;
        self.applyButton.userInteractionEnabled = NO;
    } else {
        // None
        self.applyButton.alpha = 1;
        self.applyButton.userInteractionEnabled = YES;
    }
}

- (void)updateApplying {
    self.userModel.status = LiveInteractStatusApplying;
    [self setUserModel:self.userModel];
}

- (void)resetStatus {
    self.userModel.status = LiveInteractStatusOther;
    [self setUserModel:self.userModel];
}

#pragma mark - Private Action

- (void)applyButtonAction {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoStatus == AVAuthorizationStatusAuthorized && audioStatus == AVAuthorizationStatusAuthorized) {
        if (self.clickApplyBlock) {
            self.userInteractionEnabled = NO;
            self.clickApplyBlock();
        }
    } else if (videoStatus == AVAuthorizationStatusNotDetermined || audioStatus == AVAuthorizationStatusNotDetermined) {
        if (videoStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){}];
        }
        if (audioStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){}];
        }
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"linkmic_without_permission")];
    }
}

- (void)cancelButtonAction {
    if (self.clickCancelBlock) {
        self.clickCancelBlock();
    }
}

- (void)maskAction {
    if (self.clickCancelBlock) {
        self.clickCancelBlock();
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

- (BaseButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [[BaseButton alloc] init];
        _applyButton.backgroundColor = [UIColor clearColor];
        [_applyButton setTitle:LocalizedString(@"co-host_application") forState:UIControlStateNormal];
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _applyButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_applyButton addTarget:self action:@selector(applyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyButton;
}

@end
