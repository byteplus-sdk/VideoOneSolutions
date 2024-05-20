// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullUIViewController.h"
#import "VELPullSettingCategoryView.h"
#import "VELPullAVSettingDelegate.h"
#import "VELPullAVSettingAudioViewModel.h"
#import "VELPullAVSettingVideoViewModel.h"
#import <objc/runtime.h>
#import <ToolKit/Localizator.h>
@interface VELPullUIViewController (AVControl)
@property (nonatomic, strong) VELPullSettingCategoryView *avSettingView;
@property (nonatomic, strong) VELPullAVSettingVideoViewModel *videoVM;
@property (nonatomic, strong) VELPullAVSettingAudioViewModel *audioVM;
@end

@implementation VELPullUIViewController (AV)

- (void)showAVSetting {
    if ([self isAVSettingShowing]) {
        return;
    }
    self.audioVM.currentVolume = self.currentVolume;
    self.avSettingView.alpha = 0;
    self.avSettingView.hidden = NO;
    [self.avSettingView.layer removeAllAnimations];
    [self.controlContainer.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        [self.avSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlContainer.mas_bottom).mas_offset(-340 - VEL_SAFE_INSERT.bottom);
        }];
        self.avSettingView.alpha = 1;
        [self.avSettingView layoutIfNeeded];
        [self.controlContainer layoutIfNeeded];
    }];
}

- (void)hideAVSetting {
    if (![self isAVSettingShowing]) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.avSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlContainer.mas_bottom);
        }];
        self.avSettingView.alpha = 0;
        [self.avSettingView layoutIfNeeded];
        [self.controlContainer layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.avSettingView.hidden = YES;
        }
    }];
}

- (BOOL)isAVSettingShowing {
    return self.avSettingView != nil
    && self.avSettingView.superview == self.controlContainer
    && !self.avSettingView.isHidden;
}

- (void)resetAVSettings {
    [self.videoVM resetAVSettings];
}


- (void)rotate:(int)angle {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)changeFillType:(int)fillType {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)changeMirrorType:(int)fillType {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)snapshot {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)openSR {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)closeSR {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (BOOL)isSupportSR { return NO; };
- (void)enableVideoSubscribe {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)disableVideoSubscribe {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)mute {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)unMute {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)changeVolume:(float)volume {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)enableAudioSubscribe {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)disableAudioSubscribe {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};

@end

@implementation VELPullUIViewController (AVControl)

static char kAssociatedObjectKey_avSettingView;
- (void)setAvSettingView:(VELPullSettingCategoryView *)avSettingView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_avSettingView, avSettingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELPullSettingCategoryView *)avSettingView {
    VELPullSettingCategoryView *settingView = (VELPullSettingCategoryView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_avSettingView);
    if (settingView == nil) {
        settingView = [[VELPullSettingCategoryView alloc] initWithFrame:CGRectMake(10, self.controlContainer.vel_height, 296, 340)];
        settingView.settingViewModels = @[self.videoVM, self.audioVM];
        settingView.hidden = YES;
        settingView.alpha = 0;
        [self setAvSettingView:settingView];
    }
    if (settingView.superview != self.controlContainer) {
        [settingView removeFromSuperview];
        [self.controlContainer addSubview:settingView];
        [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlContainer.mas_bottom);
            make.left.equalTo(self.controlContainer).mas_offset(10);
            make.right.equalTo(self.controlContainer).mas_offset(-70);
            make.height.mas_equalTo(340);
        }];
        [self.controlContainer setNeedsLayout];
        [self.controlContainer layoutIfNeeded];
    }
    return settingView;
}

static char kAssociatedObjectKey_videoVM;
- (void)setVideoVM:(VELPullAVSettingVideoViewModel *)videoVM {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_videoVM, videoVM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELPullAVSettingVideoViewModel *)videoVM {
    VELPullAVSettingVideoViewModel *vm = (VELPullAVSettingVideoViewModel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_videoVM);
    if (vm == nil) {
        vm = [[VELPullAVSettingVideoViewModel alloc] init];
        vm.title = LocalizedStringFromBundle(@"medialive_video", @"MediaLive");
        vm.delegate = (id<VELPullAVSettingDelegate>)self;
        [self setVideoVM:vm];
    }
    return vm;
}
static char kAssociatedObjectKey_audioVM;
- (void)setAudioVM:(VELPullAVSettingAudioViewModel *)audioVM {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_audioVM, audioVM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELPullAVSettingAudioViewModel *)audioVM {
    VELPullAVSettingAudioViewModel *vm = (VELPullAVSettingAudioViewModel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_audioVM);
    if (vm == nil) {
        vm = [[VELPullAVSettingAudioViewModel alloc] init];
        vm.title = LocalizedStringFromBundle(@"medialive_audio", @"MediaLive");
        vm.delegate = (id<VELPullAVSettingDelegate>)self;
        [self setAudioVM:vm];
    }
    return vm;
}
@end
