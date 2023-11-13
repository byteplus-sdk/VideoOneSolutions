// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveMediaComponent.h"
#import "DeviceInforTool.h"
#import "LiveGuestsMediaView.h"
#import "LiveHostMediaView.h"
#import "LiveRTCManager.h"

@interface LiveMediaComponent () <LiveHostMediaViewDelegate, LiveGuestsMediaViewDelegate>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) UIView *mediaView;

@property (nonatomic, assign) BOOL currentMic;

@property (nonatomic, assign) BOOL currentCamera;

@property (nonatomic, assign) BOOL currentFlipImage;

@end

@implementation LiveMediaComponent

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Publish Action

- (void)show:(LiveMediaStatus)status
    userModel:(LiveUserModel *)userModel {
    UIViewController *windowVC = [DeviceInforTool topViewController];
    UIView *mediaView = nil;
    CGFloat mediaViewHeight = 0;
    if (status == LiveMediaStatusHost) {
        LiveHostMediaView *hostMediaView = [[LiveHostMediaView alloc] init];
        [hostMediaView updateButtonStatus:LiveHostMediaStatusMic
                                  isStart:userModel.mic];
        [hostMediaView updateButtonStatus:LiveHostMediaStatusCamera
                                  isStart:userModel.camera];
        hostMediaView.delegate = self;
        mediaViewHeight = 134 + [DeviceInforTool getVirtualHomeHeight];
        mediaView = hostMediaView;
    } else {
        LiveGuestsMediaView *guestsMediaView = [[LiveGuestsMediaView alloc] init];
        [guestsMediaView updateButtonStatus:LiveGuestsMediaViewStatusMic
                                    isStart:userModel.mic];
        [guestsMediaView updateButtonStatus:LiveGuestsMediaViewStatusCamera
                                    isStart:userModel.camera];
        guestsMediaView.delegate = self;
        mediaViewHeight = 163 + [DeviceInforTool getVirtualHomeHeight];
        mediaView = guestsMediaView;
    }
    [windowVC.view addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(windowVC.view);
    }];

    [windowVC.view addSubview:mediaView];
    [mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(windowVC.view);
        make.bottom.equalTo(windowVC.view).offset(mediaViewHeight);
        make.height.mas_equalTo(mediaViewHeight);
    }];
    [mediaView.superview setNeedsLayout];
    [mediaView.superview layoutIfNeeded];
    self.mediaView = mediaView;
    [UIView animateWithDuration:0.25 animations:^{
        [mediaView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(windowVC.view).offset(0);
        }];
        [mediaView.superview layoutIfNeeded];
    }];

    self.currentMic = userModel.mic;
    self.currentCamera = userModel.camera;
    self.currentFlipImage = NO;
}

- (void)close {
    if (self.mediaView.superview) {
        [self.mediaView removeFromSuperview];
        self.mediaView = nil;
    }

    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
}

#pragma mark - LiveGuestsMediaViewDelegate

- (void)guestsMediaView:(LiveGuestsMediaView *)guestsMediaView
            clickButton:(LiveGuestsMediaViewStatus)status
                isStart:(BOOL)isStart {
    switch (status) {
        case LiveGuestsMediaViewStatusFilp:
            [[LiveRTCManager shareRtc] switchCamera];
            break;
        case LiveGuestsMediaViewStatusMic: {
            BOOL currentMic = !isStart;
            [self loadDataWithMediaMic:currentMic
                                 block:^(BOOL result) {
                                     [guestsMediaView updateButtonStatus:LiveGuestsMediaViewStatusMic
                                                                 isStart:currentMic];
                                 }];
            break;
        }
        case LiveGuestsMediaViewStatusCamera: {
            BOOL currentCamera = !isStart;
            [self loadDataWithMediaCamera:currentCamera
                                    block:^(BOOL result) {
                                        [guestsMediaView updateButtonStatus:LiveGuestsMediaViewStatusCamera
                                                                    isStart:currentCamera];
                                    }];
            break;
        }
        case LiveGuestsMediaViewStatusDisconnect:
            if ([self.delegate respondsToSelector:@selector(mediaComponent:clickDisconnect:)]) {
                [self.delegate mediaComponent:self clickDisconnect:YES];
            }
            break;
        case LiveGuestsMediaViewStatusCancel:
            [self close];
            break;
        default:
            break;
    }
}

#pragma mark - LiveHostMediaViewDelegate

- (void)hostMediaView:(LiveHostMediaView *)hostMediaView
          clickButton:(LiveHostMediaStatus)status
              isStart:(BOOL)isStart {
    switch (status) {
        case LiveHostMediaStatusFilp:
            self.currentFlipImage = !self.currentFlipImage;
            [hostMediaView updateFlipImage:LiveHostMediaStatusFilp currentFlipImage:self.currentFlipImage];
            [[LiveRTCManager shareRtc] switchCamera];
            break;

        case LiveHostMediaStatusMic: {
            BOOL currentMic = !isStart;
            [self loadDataWithMediaMic:currentMic
                                 block:^(BOOL result) {
                                     [hostMediaView updateButtonStatus:LiveHostMediaStatusMic
                                                               isStart:currentMic];
                                 }];
            break;
        }
        case LiveHostMediaStatusCamera: {
            BOOL currentCamera = !isStart;
            [self loadDataWithMediaCamera:currentCamera
                                    block:^(BOOL result) {
                                        [hostMediaView updateButtonStatus:LiveHostMediaStatusCamera
                                                                  isStart:currentCamera];
                                    }];
        } break;
        case LiveHostMediaStatusInfo: {
            [self close];
            [self.delegate mediaComponent:self clickStreamInfo:YES];
        } break;
        default:
            break;
    }
}

#pragma mark - Network request Method

- (void)loadDataWithMediaMic:(BOOL)mic
                       block:(void (^)(BOOL result))block {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveUpdateMediaMic:mic
                                camera:self.currentCamera
                                 block:^(RTSACKModel *_Nonnull model) {
                                     [[ToastComponent shareToastComponent] dismiss];
                                     if (!model.result) {
                                         [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                     } else {
                                         wself.currentMic = mic;
                                         [[LiveRTCManager shareRtc] switchAudioCapture:mic];
                                     }
                                     if (block) {
                                         block(model.result);
                                     }
                                 }];
}

- (void)loadDataWithMediaCamera:(BOOL)camera
                          block:(void (^)(BOOL result))block {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveUpdateMediaMic:self.currentMic
                                camera:camera
                                 block:^(RTSACKModel *_Nonnull model) {
                                     [[ToastComponent shareToastComponent] dismiss];
                                     if (!model.result) {
                                         [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                     } else {
                                         wself.currentCamera = camera;
                                         [[LiveRTCManager shareRtc] switchVideoCapture:camera];
                                     }
                                     if (block) {
                                         block(model.result);
                                     }
                                 }];
}

#pragma mark - Private Action

- (void)maskViewAction {
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }

    if (self.mediaView.superview) {
        [self.mediaView removeFromSuperview];
        self.mediaView = nil;
    }
}

#pragma mark - Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

@end
