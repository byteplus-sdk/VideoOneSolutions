// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/Localizator.h>
#define VEL_PUSH_INFO_HEIGHT (250)
@implementation VELPushUIViewController (Info)
- (void)showInfoView {
    if ([self isInfoViewShowing]) {
        return;
    }
    UIView *infoView = self.infoSettingVM.settingsView;
    infoView.alpha = 0;
    infoView.hidden = NO;
    [infoView.layer removeAllAnimations];
    [self.popControlView.layer removeAllAnimations];
    if (infoView.superview != self.popControlView) {
        [infoView removeFromSuperview];
        [self.popControlView addSubview:infoView];
    }
    [self layoutInfoView:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutInfoView:YES];
        infoView.alpha = 1;
    }];
    self.currentPopObj = self.infoViewModel;
}

- (void)hideInfoView {
    if (![self isInfoViewShowing]) {
        return;
    }
    UIView *infoView = self.infoSettingVM.settingsView;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutInfoView:NO];
        infoView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            infoView.hidden = YES;
        }
    }];
    if (self.currentPopObj == self.infoViewModel) {
        self.currentPopObj = nil;
    }
}

- (void)layoutInfoView:(BOOL)show {
    [self.infoSettingVM.settingsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (show) {
            make.top.equalTo(self.popControlView.mas_bottom).mas_offset(-VEL_PUSH_INFO_HEIGHT);
        } else {
            make.top.equalTo(self.popControlView.mas_bottom);
        }
        make.left.equalTo(self.popControlView);
        make.right.equalTo(self.popControlView);
        make.height.mas_equalTo(VEL_PUSH_INFO_HEIGHT);
    }];
    [self.popControlView setNeedsLayout];
    [self.popControlView layoutIfNeeded];
    [self.infoSettingVM.settingsView setNeedsLayout];
    [self.infoSettingVM.settingsView layoutIfNeeded];
}

- (BOOL)isInfoViewShowing {
    return [self.infoSettingVM isShowingOnView:self.popControlView];
}

- (void)setupInfoViews {
    [self.infoViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.infoViews removeAllObjects];
    if (!self.cycleInfoView.isHidden) {
        [self.infoViews addObject:self.cycleInfoView];
        [self.infoContainer addSubview:self.cycleInfoView];
    }
    if (!self.callBackInfoView.isHidden) {
        [self.infoViews addObject:self.callBackInfoView];
        [self.infoContainer addSubview:self.callBackInfoView];
    }
    
    if (self.infoViews.count == 0) {
        [self.infoScrollView removeFromSuperview];
        return;
    }
    
    if (self.infoScrollView.superview != self.controlContainerView) {
        [self.controlContainerView insertSubview:self.infoScrollView atIndex:0];
    }
    [self.infoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.controlContainerView).mas_offset(VEL_NAVIGATION_HEIGHT + 30);
        
        if (VELDeviceHelper.isLandSpace) {
            make.left.equalTo(self.controlContainerView).mas_offset(40);
            make.right.equalTo(self.streamingControl.mas_left).mas_offset(-10);
            make.bottom.lessThanOrEqualTo(self.controlContainerView).mas_offset(VEL_SAFE_INSERT.bottom);
        } else {
            make.left.equalTo(self.controlContainerView).mas_offset(10);
            make.right.equalTo(self.streamingControl.mas_left).mas_offset(-10);
            make.bottom.lessThanOrEqualTo(self.controlContainerView).mas_offset(-VEL_PUSH_INFO_HEIGHT - VEL_SAFE_INSERT.bottom);
        }
    }];
    
    if (self.infoViews.count > 1) {
        [self.infoViews mas_distributeViewsAlongAxis:(MASAxisTypeVertical) withFixedSpacing:6 leadSpacing:0 tailSpacing:0];
        [self.infoViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(100);
            make.left.right.equalTo(self.infoContainer);
        }];
        [self.infoViews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoContainer);
        }];
        [self.infoViews.lastObject mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.infoContainer);
        }];
    } else {
        [self.infoViews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.infoContainer);
            make.height.mas_equalTo(100);
        }];
    }
}

- (void)updateCycleInfo:(NSString *)info append:(BOOL)append {
    vel_async_main_queue(^{
        [self.cycleInfoView updateInfo:info append:append];
    });
}

- (void)updateCallBackInfo:(NSString *)info append:(BOOL)append {
    vel_async_main_queue(^{
        [self.callBackInfoView updateInfo:info append:append date:NSDate.date];
    });
}

- (void)showCycleInfo {
    self.cycleInfoView.hidden = NO;
    [self setupInfoViews];
}

- (void)hideCycleInfo {
    self.cycleInfoView.hidden = YES;
    [self setupInfoViews];
}

- (void)showCallbackNote {
    self.callBackInfoView.hidden = NO;
    [self setupInfoViews];
}

- (void)hideCallbackNote {
    self.callBackInfoView.hidden = YES;
    [self setupInfoViews];
}
@end

@implementation VELPushUIViewController (InfoControl)

- (void)hideAllConsoleInfoView {
    _logInfoView.hidden = YES;
    _callBackInfoView.hidden = YES;
    _cycleInfoView.hidden = YES;
    [self setupInfoViews];
}

- (NSMutableArray<VELConsoleView *> *)infoViews {
    if (!_infoViews) {
        _infoViews = [NSMutableArray arrayWithCapacity:3];
    }
    return _infoViews;
}

- (VELConsoleView *)cycleInfoView {
    if (_cycleInfoView == nil) {
        _cycleInfoView = [[VELConsoleView alloc] init];
        _cycleInfoView.title = LocalizedStringFromBundle(@"medialive_cycle_info", @"MediaLive");
        _cycleInfoView.hidden = YES;
    }
    return _cycleInfoView;
}

- (VELConsoleView *)callBackInfoView {
    if (_callBackInfoView == nil) {
        _callBackInfoView = [[VELConsoleView alloc] init];
        _callBackInfoView.title = LocalizedStringFromBundle(@"medialive_callback_info", @"MediaLive");
        _callBackInfoView.hidden = YES;
        _callBackInfoView.showDate = YES;
    }
    return _callBackInfoView;
}


- (_VELPushInfoUIScrollView *)infoScrollView {
    if (_infoScrollView == nil) {
        _infoScrollView = [[_VELPushInfoUIScrollView alloc] init];
        _infoScrollView.backgroundColor = [UIColor clearColor];
        _infoScrollView.showsVerticalScrollIndicator = NO;
        _infoScrollView.showsHorizontalScrollIndicator = NO;
        _infoScrollView.layer.cornerRadius = 16;
        _infoScrollView.clipsToBounds = YES;
        [_infoScrollView addSubview:self.infoContainer];
        [self.infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_infoScrollView);
            make.width.equalTo(_infoScrollView);
        }];
    }
    return _infoScrollView;
}

- (UIView *)infoContainer {
    if (_infoContainer == nil) {
        _infoContainer = [[UIView alloc] init];
    }
    return _infoContainer;
}

- (VELPushSettingInfoViewModel *)infoSettingVM {
    if (_infoSettingVM == nil) {
        _infoSettingVM = [[VELPushSettingInfoViewModel alloc] init];
        _infoSettingVM.delegate = self;
    }
    return _infoSettingVM;
}
@end

