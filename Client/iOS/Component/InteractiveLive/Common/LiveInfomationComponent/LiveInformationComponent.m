// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInformationComponent.h"
#import "LiveInfomationContentView.h"
#import "LiveRTCInteract.h"
#import "LiveRTCManager.h"

@interface LiveInformationComponent ()

@property (nonatomic, strong) UIView *infoMaskView;

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) LiveInfomationContentView *contentView;
@property (nonatomic, strong) LiveInformationStreamModel *streamModel;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation LiveInformationComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
        _streamModel = [LiveInformationStreamModel new];
    }
    return self;
}

#pragma mark - Publish Action

- (void)show {
    if (self.contentView.superview != nil || self.refreshTimer != nil) {
        return;
    }
    if (![self.linkSession isInteracting]) {
        [[ToastComponent shareToastComponent] showLoading];
    }
    [self.superView addSubview:self.infoMaskView];
    [self.infoMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];

    CGFloat contentViewHeight = 509;
    [self.superView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.superView);
        make.bottom.equalTo(self.superView).offset(contentViewHeight);
        make.height.mas_equalTo(contentViewHeight);
    }];
    [self.contentView.superview setNeedsLayout];
    [self.contentView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.superView).offset(0);
        }];
        [self.contentView.superview layoutIfNeeded];
    }];

    [self updateStreamModelBasicIfNeeded];
    [self updateStreamModelRealTime];
    self.contentView.basicDataLists = [self getBasicDataLists];
    self.contentView.realTimeDataLists = [self getRealTimeDataLists];
    [self.contentView refresh];
    [[ToastComponent shareToastComponent] dismiss];

    // 面板可见期间每秒刷新一次实时指标；加入 CommonModes 防止列表滚动时暂停。
    __weak __typeof(self) wself = self;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(__unused NSTimer * _Nonnull t) {
        __strong __typeof(wself) sself = wself;
        if (!sself) {
            [t invalidate];
            return;
        }
        [sself updateStreamModelRealTime];
        sself.contentView.realTimeDataLists = [sself getRealTimeDataLists];
        [sself.contentView refresh];
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.refreshTimer = timer;
}

#pragma mark - Private Action

- (LivePushStreamParams *)currentPushStreamParams {
    id streaming = nil;
    @try {
        streaming = [self.linkSession valueForKey:@"interactivePushStreaming"];
    } @catch (__unused NSException *exception) {
        streaming = nil;
    }
    if ([streaming isKindOfClass:LiveRTCInteract.class]) {
        return ((LiveRTCInteract *)streaming).streamParams;
    }
    return nil;
}

- (void)updateStreamModelBasicIfNeeded {
    // 基础信息来源于当前推流配置，面板展示期间保持稳定
    LivePushStreamParams *params = [self currentPushStreamParams];
    if (!params) {
        return;
    }
    self.streamModel.defaultBitrate = MAX(0, params.defaultBitrate);
    self.streamModel.minBitrate = MAX(0, params.minBitrate);
    self.streamModel.maxBitrate = MAX(0, params.maxBitrate);
    self.streamModel.defaultFps = MAX(0, params.fps);

    NSString *resolution = nil;
    if (params.width > 0 && params.height > 0) {
        resolution = [NSString stringWithFormat:@"%ld*%ld", (long)params.width, (long)params.height];
    } else {
        resolution = @"--";
    }
    self.streamModel.captureResolution = resolution;
    self.streamModel.pushResolution = resolution.copy;

    // 编码格式：当前 RTC 推流固定使用 H264 硬编（见 LiveRTCMixer）
    self.streamModel.encodeFormat = @"H264(hardware)";

    // 自适应码率：min/max 不相等即认为启用了动态码率（normal），否则为 none
    BOOL adaptiveEnabled = (params.minBitrate > 0
                            && params.maxBitrate > 0
                            && params.minBitrate != params.maxBitrate);
    self.streamModel.adaptiveBitrateMode = adaptiveEnabled ? @"normal" : @"none";
}

- (void)updateStreamModelRealTime {
    LiveRTCManager *rtc = [LiveRTCManager shareRtc];
    self.streamModel.captureFps = MAX(0, rtc.captureFps);
    self.streamModel.transFps = MAX(0, rtc.transportFps);
    self.streamModel.realTimeEncodeBitrate = MAX(0, rtc.encodeBitrateKbps);
    self.streamModel.realTimeTransBitrate = MAX(0, rtc.transportBitrateKbps);
    if (rtc.encodeResolution.width > 0 && rtc.encodeResolution.height > 0) {
        self.streamModel.pushResolution = [NSString stringWithFormat:@"%ld*%ld",
                                           (long)rtc.encodeResolution.width,
                                           (long)rtc.encodeResolution.height];
    }
}

- (NSArray *)getRealTimeDataLists {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveInfomationModel *model1 = [[LiveInfomationModel alloc] init];
    model1.title = LocalizedString(@"real-time_capture_fps");
    model1.value = [NSString stringWithFormat:@"%ld", self.streamModel.captureFps];
    [list addObject:model1];

    LiveInfomationModel *model2 = [[LiveInfomationModel alloc] init];
    model2.title = LocalizedString(@"real-time_transmission_fps");
    model2.value = [NSString stringWithFormat:@"%ld", self.streamModel.transFps];
    [list addObject:model2];

    LiveInfomationModel *model3 = [[LiveInfomationModel alloc] init];
    model3.title = LocalizedString(@"real-time_encoding_bitrate");
    model3.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.realTimeEncodeBitrate];
    model3.isSegmentation = YES;
    [list addObject:model3];

    LiveInfomationModel *model4 = [[LiveInfomationModel alloc] init];
    model4.title = LocalizedString(@"real-time_transmission_bitrate");
    model4.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.realTimeTransBitrate];
    [list addObject:model4];

    return [list copy];
}

- (NSArray *)getBasicDataLists {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveInfomationModel *model1 = [[LiveInfomationModel alloc] init];
    model1.title = LocalizedString(@"initial_video_bitrate");
    model1.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.defaultBitrate];
    [list addObject:model1];

    LiveInfomationModel *model2 = [[LiveInfomationModel alloc] init];
    model2.title = LocalizedString(@"maximum_video_bitrate");
    model2.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.maxBitrate];
    [list addObject:model2];

    LiveInfomationModel *model3 = [[LiveInfomationModel alloc] init];
    model3.title = LocalizedString(@"minimum_video_bitrate");
    model3.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.minBitrate];
    [list addObject:model3];

    LiveInfomationModel *model4 = [[LiveInfomationModel alloc] init];
    model4.title = LocalizedString(@"capture_resolution");
    model4.value = self.streamModel.captureResolution;
    model4.isSegmentation = YES;
    [list addObject:model4];

    LiveInfomationModel *model5 = [[LiveInfomationModel alloc] init];
    model5.title = LocalizedString(@"push_video_resolution");
    model5.value = self.streamModel.pushResolution;
    [list addObject:model5];

    LiveInfomationModel *model6 = [[LiveInfomationModel alloc] init];
    model6.title = LocalizedString(@"capture_fps");
    model6.value = [NSString stringWithFormat:@"%ld", self.streamModel.defaultFps];
    [list addObject:model6];

    LiveInfomationModel *model7 = [[LiveInfomationModel alloc] init];
    model7.title = LocalizedString(@"encoding_format");
    //h264/hardware = 1
    model7.value = self.streamModel.encodeFormat;
    [list addObject:model7];

    LiveInfomationModel *model8 = [[LiveInfomationModel alloc] init];
    model8.title = LocalizedString(@"adaptive_bitrate_mode");
    // adaptive_bitrate_none adaptive_bitrate_normal
    NSString *valueKey = self.streamModel.adaptiveBitrateMode;
    if (NOEmptyStr(self.streamModel.adaptiveBitrateMode)) {
        valueKey = [NSString stringWithFormat:@"adaptive_bitrate_%@", [self.streamModel.adaptiveBitrateMode lowercaseString]];
    }
    model8.value = LocalizedString(valueKey);
    [list addObject:model8];

    return [list copy];
}

- (void)dismiss {
    if (self.refreshTimer) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    if (self.infoMaskView.superview) {
        [self.infoMaskView removeFromSuperview];
        self.infoMaskView = nil;
    }

    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
    [[ToastComponent shareToastComponent] dismiss];
}

- (void)dealloc {
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
}

- (void)setRefreshTimer:(NSTimer *)refreshTimer {
    if (_refreshTimer != refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = refreshTimer;
    }
}

#pragma mark - Getter

- (LiveInfomationContentView *)contentView {
    if (!_contentView) {
        _contentView = [[LiveInfomationContentView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:1 * 255];
    }
    return _contentView;
}

- (UIView *)infoMaskView {
    if (!_infoMaskView) {
        _infoMaskView = [[UIView alloc] init];
        _infoMaskView.backgroundColor = [UIColor clearColor];
        _infoMaskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_infoMaskView addGestureRecognizer:tap];
    }
    return _infoMaskView;
}

@end
