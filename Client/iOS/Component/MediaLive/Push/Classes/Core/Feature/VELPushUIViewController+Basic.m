// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import <ToolKit/Localizator.h>
@implementation VELPushUIViewController (Basic)
- (void)setNetworkQuality:(VELNetworkQuality)networkQuality {
    self->_networkQuality = networkQuality;
    self.netQualityView.level = (int)networkQuality;
}
- (void)setStreamStatus:(VELStreamStatus)streamStatus msg:(NSString *)msg {
    if (self->_streamStatus == streamStatus) {
        return;
    }
    self->_streamStatus = streamStatus;
    [VELUIToast hideAllToast];
    static int retryReconnectCount = 0;
    if (streamStatus == VELStreamStatusNone
        || streamStatus == VELStreamStatusEnded
        || streamStatus == VELStreamStatusError
        || streamStatus == VELStreamStatusStop) {
        [self setupUIForNotStreaming];
        retryReconnectCount = 0;
        if (streamStatus == VELStreamStatusError) {
            [VELUIToast showText:msg?:LocalizedStringFromBundle(@"medialive_toast_error", @"MediaLive") inView:self.controlContainerView];
        } else if (streamStatus == VELStreamStatusEnded) {
            [VELUIToast showText:msg?:LocalizedStringFromBundle(@"medialive_toast_push_stop", @"MediaLive") inView:self.controlContainerView];
        }
    } else if (streamStatus == VELStreamStatusConnecting) {
        [VELUIToast showLoading:msg?:LocalizedStringFromBundle(@"medialive_toast_push_connecting", @"MediaLive") inView:self.controlContainerView hideAfterDelay:NSIntegerMax];
        [self setupUIForStreaming];
    } else if (streamStatus == VELStreamStatusConnected) {
        [VELUIToast showText:msg?:LocalizedStringFromBundle(@"medialive_toast_error", @"MediaLive") inView:self.controlContainerView];
        [self setupUIForStreaming];
        retryReconnectCount = 0;
    } else if (streamStatus == VELStreamStatusReconnecting) {
        [self setupUIForStreaming];
        [VELUIToast showLoading:[NSString stringWithFormat:@"%@-(%ld)", LocalizedStringFromBundle(@"medialive_toast_push_reconnecting", @"MediaLive"),++retryReconnectCount]
                         inView:self.controlContainerView
                 hideAfterDelay:NSIntegerMax];
    }
    if (self.streamStatusChangedBlock) {
        self.streamStatusChangedBlock(streamStatus, self.isStreaming);
    }
}
- (void)restartEngine {
    [self stopEngineAndPreview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startEngineAndPreview];
    });
}

- (VELNetworkQualityView *)netQualityView {
    if (!_netQualityView) {
        _netQualityView = [[VELNetworkQualityView alloc] init];
    }
    return _netQualityView;
}

- (void)setupCapture {};
- (void)startVideoCapture {};
- (void)stopVideoCapture {};
- (void)startAudioCapture {};
- (void)stopAudioCapture {};
- (void)switchCamera {};
- (void)muteAudio {};
- (void)unMuteAudio {};
- (void)startPreivew {};
- (void)setupEngine {};
- (void)destoryEngine {};
- (void)startStreaming {};
- (BOOL)isStreaming { return NO; };
- (void)stopStreaming {};
- (NSAttributedString *)getPushInfoString { return [[NSAttributedString alloc] initWithString:@""]; };
- (BOOL)isSupportTorch { return NO;};
- (void)torch:(BOOL)isOn {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)rotatedTo:(UIInterfaceOrientation)orientation {};
- (void)setPreviewMirror:(BOOL)mirror {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)setStreamMirror:(BOOL)mirror {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)setCaptureMirror:(BOOL)mirror { [VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")]; };
- (void)setEnableAudioHardwareEcho:(BOOL)enable {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (BOOL)isSupportAudioHardwareEcho { return NO; };
- (BOOL)isHardwareEchoEnable { return NO;};
- (void)setAudioLoudness:(float)loudness {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)setPreviewRenderMode:(VELSettingPreviewRenderMode)renderMode {};
- (float)getCurrentAudioLoudness {return 0;};
- (void)updateVideoEncodeResolution:(VELSettingResolutionType)resolution {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)updateVideoEncodeFps:(int)fps {[VELUIToast showText:LocalizedStringFromBundle(@"medialive_not_support_now", @"MediaLive")];};
- (void)reconfigCapture {};
- (void)reconfigStream {};
@end
