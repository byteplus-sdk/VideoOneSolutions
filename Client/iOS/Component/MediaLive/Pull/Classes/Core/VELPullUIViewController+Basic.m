// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullUIViewController.h"
#import "VELPullSettingCategoryView.h"
#import "VELPullBasicSettingDelegate.h"
#import "VELBasicSettingPlayControlViewModel.h"
#import "VELBasicSettingPlayInfoViewModel.h"
#import <objc/runtime.h>
#import <ToolKit/Localizator.h>
@interface _VELPullUIScrollView : UIScrollView
@end
@implementation _VELPullUIScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}

@end
@interface VELPullUIViewController () <VELPullBasicSettingDelegate>
@property (nonatomic, strong) VELPullSettingCategoryView *basicSettingView;
@property (nonatomic, strong) _VELPullUIScrollView *infoScrollView;
@property (nonatomic, strong) UIView *infoContainer;
@property (nonatomic, strong) NSMutableArray <VELConsoleView *>* infoViews;
@property (nonatomic, strong) VELConsoleView *cycleInfoView;
@property (nonatomic, strong) VELConsoleView *callBackInfoView;
@property (nonatomic, strong) VELBasicSettingPlayControlViewModel *controlVM;
@property (nonatomic, strong) VELBasicSettingPlayInfoViewModel *infoVM;
@end

@implementation VELPullUIViewController (Basic)
- (void)showBasicSetting {
    if ([self isBasicSettingShowing]) {
        return;
    }
    [self.controlVM setShouldPlayInBackground:self.isShouldPlayInBackground];
    [self.controlVM setSupportResolutions:self.getCurrentSupportResolutions
                        defaultResolution:self.getCurrentResolution];
    
    self.basicSettingView.alpha = 0;
    self.basicSettingView.hidden = NO;
    [self.basicSettingView.layer removeAllAnimations];
    [self.controlContainer.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        [self.basicSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlContainer.mas_bottom).mas_offset(-340 - VEL_SAFE_INSERT.bottom);
        }];
        self.basicSettingView.alpha = 1;
        [self.basicSettingView layoutIfNeeded];
        [self.controlContainer layoutIfNeeded];
    }];
}

- (void)refreshCurrentResolution {
    vel_async_main_queue(^{
        if (!self.isBasicSettingShowing) {
            return;
        }
        [self.controlVM setSupportResolutions:self.getCurrentSupportResolutions
                            defaultResolution:self.getCurrentResolution];        
    });
}

- (void)hideBasicSetting {
    if (![self isBasicSettingShowing]) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.basicSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlContainer.mas_bottom);
        }];
        self.basicSettingView.alpha = 0;
        [self.basicSettingView layoutIfNeeded];
        [self.controlContainer layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.basicSettingView.hidden = YES;
        }
    }];
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
    if (self.infoScrollView.superview != self.controlContainer) {
        [self.controlContainer insertSubview:self.infoScrollView atIndex:0];
    }
    [self.infoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.controlContainer).mas_offset(VEL_NAVIGATION_HEIGHT + 20);
        make.left.equalTo(self.controlContainer).mas_offset(10);
        make.right.equalTo(self.controlContainer).mas_offset(-10);
        make.bottom.lessThanOrEqualTo(self.basicSettingView.mas_top).mas_offset(-50);
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

- (BOOL)isBasicSettingShowing {
    return self.basicSettingView != nil
    && self.basicSettingView.superview == self.controlContainer
    && !self.basicSettingView.isHidden;
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

static char kAssociatedObjectKey_basicSettingView;
- (void)setBasicSettingView:(VELPullSettingCategoryView *)basicSettingView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_basicSettingView, basicSettingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (VELPullSettingCategoryView *)basicSettingView {
    VELPullSettingCategoryView *settingView = (VELPullSettingCategoryView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_basicSettingView);
    if (settingView == nil) {
        settingView = [[VELPullSettingCategoryView alloc] initWithFrame:CGRectMake(10, self.controlContainer.vel_height, 296, 340)];
        settingView.settingViewModels = @[self.controlVM, self.infoVM];
        settingView.hidden = YES;
        settingView.alpha = 0;
        [self setBasicSettingView:settingView];
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
static char kAssociatedObjectKey_infoViews;
- (void)setInfoViews:(NSMutableArray<VELConsoleView *> *)infoViews {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_infoViews, infoViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<VELConsoleView *> *)infoViews {
    NSMutableArray <VELConsoleView *>* infoViews = (NSMutableArray <VELConsoleView *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_infoViews);
    if (infoViews == nil) {
        infoViews = [NSMutableArray arrayWithCapacity:3];
        [self setInfoViews:infoViews];
    }
    return infoViews;
}

static char kAssociatedObjectKey_cycleInfoView;
- (void)setCycleInfoView:(VELConsoleView *)cycleInfoView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cycleInfoView, cycleInfoView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELConsoleView *)cycleInfoView {
    VELConsoleView *infoView = (VELConsoleView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cycleInfoView);
    if (infoView == nil) {
        infoView = [[VELConsoleView alloc] init];
        infoView.title = LocalizedStringFromBundle(@"medialive_cycle_info", @"MediaLive");
        infoView.hidden = YES;
        [self setCycleInfoView:infoView];
    }
    return infoView;
}

static char kAssociatedObjectKey_callBackInfoView;
- (void)setCallBackInfoView:(VELConsoleView *)callBackInfoView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_callBackInfoView, callBackInfoView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELConsoleView *)callBackInfoView {
    VELConsoleView *infoView = (VELConsoleView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_callBackInfoView);
    if (infoView == nil) {
        infoView = [[VELConsoleView alloc] init];
        infoView.title = LocalizedStringFromBundle(@"medialive_callback_info", @"MediaLive");
        infoView.hidden = YES;
        infoView.showDate = YES;
        [self setCallBackInfoView:infoView];
    }
    return infoView;
}

static char kAssociatedObjectKey_infoScrollView;
- (void)setInfoScrollView:(_VELPullUIScrollView *)infoScrollView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_infoScrollView, infoScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_VELPullUIScrollView *)infoScrollView {
    _VELPullUIScrollView *infoScrollView = (_VELPullUIScrollView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_infoScrollView);
    if (infoScrollView == nil) {
        infoScrollView = [[_VELPullUIScrollView alloc] init];
        infoScrollView.backgroundColor = [UIColor clearColor];
        infoScrollView.showsVerticalScrollIndicator = NO;
        infoScrollView.showsHorizontalScrollIndicator = NO;
        infoScrollView.layer.cornerRadius = 16;
        infoScrollView.clipsToBounds = YES;
        [infoScrollView addSubview:self.infoContainer];
        [self.infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(infoScrollView);
            make.width.equalTo(infoScrollView);
        }];
        [self setInfoScrollView:infoScrollView];
    }
    return infoScrollView;
}

static char kAssociatedObjectKey_infoContainer;
- (void)setInfoContainer:(UIView *)infoContainer {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_infoContainer, infoContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)infoContainer {
    UIView *infoContainer = (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_infoContainer);
    if (infoContainer == nil) {
        infoContainer = [[UIView alloc] init];
        [self setInfoContainer:infoContainer];
    }
    return infoContainer;
}
static char kAssociatedObjectKey_controlVM;
- (void)setControlVM:(VELBasicSettingPlayControlViewModel *)controlVM {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_controlVM, controlVM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELBasicSettingPlayControlViewModel *)controlVM {
    VELBasicSettingPlayControlViewModel *vm = (VELBasicSettingPlayControlViewModel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_controlVM);
    if (vm == nil) {
        vm = [[VELBasicSettingPlayControlViewModel alloc] init];
        vm.title = LocalizedStringFromBundle(@"medialive_play_control", @"MediaLive");
        vm.delegate = self;
        [self setControlVM:vm];
    }
    return vm;
}

static char kAssociatedObjectKey_infoVM;
- (void)setInfoVM:(VELBasicSettingPlayInfoViewModel *)infoVM {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_infoVM, infoVM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELBasicSettingPlayInfoViewModel *)infoVM {
    VELBasicSettingPlayInfoViewModel *vm = (VELBasicSettingPlayInfoViewModel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_infoVM);
    if (vm == nil) {
        vm = [[VELBasicSettingPlayInfoViewModel alloc] init];
        vm.title =  LocalizedStringFromBundle(@"medialive_info_display", @"MediaLive");
        vm.delegate = self;
        [self setInfoVM:vm];
    }
    return vm;
}

- (void)setupPlayer {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)destroyPlayer {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (BOOL)isPlaying {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer]; return NO;};
- (void)preload {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)play {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)playWithNetworkReachable {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)pause {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)resume {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)stop {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)startPlayInBackground {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)stopPlayInBackground {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (BOOL)resolutionShouldChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution{return NO;};
- (void)resolutionDidChanged:(VELPullResolutionType)fromResolution to:(VELPullResolutionType)toResolution{[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)openHDR {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (void)closeHDR {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer];};
- (BOOL)isSupportHDR {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive") inView:self.playerContainer]; return NO;};
- (NSArray<NSNumber *> *)getCurrentSupportResolutions { return @[]; };
- (VELPullResolutionType)getCurrentResolution { return (VELPullResolutionType)self.getCurrentSupportResolutions.firstObject.integerValue; };

@end
