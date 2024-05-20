// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Private_h
#define VELPushUIViewController_Private_h

#import "VELPushUIViewController.h"
#import "VELPushUIViewController+Device.h"
#import "VELPushUIViewController+Preview.h"
#import "VELPushUIViewController+Info.h"
#import "VELPushUIViewController+Stream.h"
#import "VELPushUIViewController+Effect.h"
#import "VELPushUIViewController+Basic.h"
#import "VELPushUIViewController+SEI.h"
#import <Masonry/Masonry.h>
#import <MediaLive/VELCommon.h>
#import <MediaLive/VELSettings.h>
NS_ASSUME_NONNULL_BEGIN
@interface _VELPushUIPopControlView : UIView
@end
@interface _VELPushInfoUIScrollView : UIScrollView
@end

@interface VELPushUIViewController () <UIGestureRecognizerDelegate> {
    VELNetworkQuality _networkQuality;
    VELStreamStatus _streamStatus;
    VELSettingsCollectionView * _previewControl;
    VELSettingsCollectionView * _streamingControl;
    VELSettingsButtonViewModel * _torchViewModel;
    VELSettingsButtonViewModel * _cameraViewModel;
    VELSettingsButtonViewModel * _micViewModel;
    VELSettingsButtonViewModel * _effectViewModel;
    VELSettingsButtonViewModel * _rotateViewModel;
    VELSettingsButtonViewModel * _previewSettingViewModel;
    VELSettingsButtonViewModel * _streamSettingViewModel;
    VELSettingsButtonViewModel * _infoViewModel;
    VELSettingsTableView * _pushSettingView;
    VELSettingsRecordViewModel * _recordViewModel;
    VELSettingsMirrorViewModel * _mirrorViewModel;
    VELSettingPushACfgViewModel * _aCfgViewModel;
    VELSettingPushVCfgViewModel * _vCfgViewModel;
    VELSettingsInputActionViewModel * _seiViewModel;
    VELPushSettingViewController *_previewSettingVC;
    VELNetworkQualityView * _netQualityView;
    UIScrollView * _pushInfoLabelContainer;
    VELUILabel * _pushInfoLabel;
    NSTimer * _infoUpdateTimer;
    NSTimer * _recordTimer;
    NSTimeInterval _recordTime;
    VELFocusView * _focusView;
    VELUILabel * _scaleLabel;
    _VELPushInfoUIScrollView *_infoScrollView;
    NSMutableArray <VELConsoleView *>* _infoViews;
    VELConsoleView *_cycleInfoView;
    VELConsoleView *_logInfoView;
    VELConsoleView *_callBackInfoView;
    VELPushSettingInfoViewModel *_infoSettingVM;
    UIView *_infoContainer;
    @protected
    BytedEffectProtocol *_beautyComponent;
}
@property (nonatomic, strong, readwrite) UIView *previewContainer;
@property (nonatomic, strong, readwrite) UIView *controlContainerView;
@property (nonatomic, strong) VELGestureManager *controlGesture;
@property (nonatomic, strong) _VELPushUIPopControlView *popControlView;
@property (nonatomic, strong) VELUIButton *startPushBtn;
@property (nonatomic, weak) id currentPopObj;
@end

@interface VELPushUIViewController (Private)
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *torchViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *cameraViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *micViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *effectViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *rotateViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *previewSettingViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *streamSettingViewModel;
@property (nonatomic, strong, readonly) VELSettingsButtonViewModel *infoViewModel;
- (void)hideAllPopView;
- (void)attemptToCurrentDeviceOrientation;
- (VELSettingsButtonViewModel *)buttonModelWithTitle:(NSString *)title
                                             image:(UIImage *)image
                                         actionBlock:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))actionBlock;
- (VELSettingsButtonViewModel *)buttonModelWithTitle:(NSString *)title
                                             image:(UIImage *)image
                                         selectImg:(UIImage *)selectImg
                                         actionBlock:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))actionBlock;
@end

@protocol VELScrollViewAdditionProtocol <NSObject>
@property(nonatomic, assign) BOOL shouldIgnoreScrollingAdjustment;
@property(nonatomic, assign) BOOL shouldRestoreScrollViewContentOffset;
@end
NS_ASSUME_NONNULL_END
#endif /* VELPushUIViewController_Private_h */





