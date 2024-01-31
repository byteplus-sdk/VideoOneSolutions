// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomSettingComponent.h"
#import "LiveCreateRoomSettingView.h"
#import "LiveRTCManager.h"
#import "LiveSettingQualityView.h"
#import "LiveSettingVideoConfig.h"

@interface LiveRoomSettingComponent () <LiveCreateRoomSettingViewDelegate>

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) LiveSettingQualityView *qualityView;

@property (nonatomic, strong) LiveCreateRoomSettingView *createRoomSettingView;

@end

@implementation LiveRoomSettingComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
    }
    return self;
}

- (void)show {
    [self.superView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];

    CGFloat height = 300 + [DeviceInforTool getVirtualHomeHeight];
    [self.superView addSubview:self.createRoomSettingView];
    [self.createRoomSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.superView);
        make.bottom.equalTo(self.superView).offset(height);
        make.height.mas_equalTo(height);
    }];
    [self.superView setNeedsLayout];
    [self.superView layoutIfNeeded];

    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.createRoomSettingView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.superView).offset(0);
                         }];
                         [self.superView layoutIfNeeded];
                     }];
}

#pragma mark - LiveCreateRoomSettingViewDelegate

- (void)liveCreateRoomSettingView:(nonnull LiveCreateRoomSettingView *)settingView
                 didChangeBitrate:(NSInteger)bitrate {
    //    LiveSettingVideoConfig *videoConfig = settingView.videoConfig;
    //    [[LiveRTCManager shareRtc] updateLiveTranscodingBitRate:videoConfig.bitrate];
}

- (void)didChangeResolution {
    LiveSettingVideoConfig *videoConfig = [LiveSettingVideoConfig defaultVideoConfig];
    [[LiveRTCManager shareRtc] updateVideoEncoderResolution:videoConfig.videoSize];
}

- (void)liveCreateRoomSettingView:(nonnull LiveCreateRoomSettingView *)settingView
                 didChangefpsType:(LiveSettingVideoFpsType)fps {
    LiveSettingVideoConfig *videoConfig = settingView.videoConfig;
    [[LiveRTCManager shareRtc] updateVideoEncoderFrameRate:videoConfig.fps];
}

- (void)liveCreateRoomSettingView:(LiveCreateRoomSettingView *)settingView
                 didSelectQuality:(BOOL)isSelect {
    LiveSettingVideoResolutionType resType = [LiveSettingVideoConfig defaultVideoConfig].resolutionType;
    NSDictionary *resolutionDic = [LiveSettingVideoConfig defaultVideoConfig].resolutionDic;
    NSString *resKey = resolutionDic[@(resType)];
    __block LiveSettingQualityView *qualityView = [[LiveSettingQualityView alloc] initWithKey:resKey];
    CGFloat height = 300 + [DeviceInforTool getVirtualHomeHeight];
    [self.superView addSubview:qualityView];
    [qualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superView).offset(SCREEN_WIDTH);
        make.right.equalTo(self.superView);
        make.bottom.equalTo(self.superView).offset(0);
        make.height.mas_equalTo(height);
    }];
    self.qualityView = qualityView;
    [self.superView setNeedsLayout];
    [self.superView layoutIfNeeded];

    [UIView animateWithDuration:0.15
                     animations:^{
                         [qualityView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.left.equalTo(self.superView).offset(0);
                         }];
                         [self.superView layoutIfNeeded];
                     }];

    __weak __typeof(self) wself = self;
    qualityView.clickBackBlock = ^{
        [qualityView removeFromSuperview];
        qualityView = nil;
    };
    qualityView.clickItemBlock = ^(NSString *_Nonnull key) {
        NSNumber *typeNumber = nil;
        for (int i = 0; i < resolutionDic.allValues.count; i++) {
            NSString *value = resolutionDic.allValues[i];
            if ([value isEqualToString:key]) {
                typeNumber = resolutionDic.allKeys[i];
                break;
            }
        }
        [LiveSettingVideoConfig defaultVideoConfig].resolutionType = typeNumber.integerValue;
        wself.createRoomSettingView.videoConfig = [LiveSettingVideoConfig defaultVideoConfig];
        [wself didChangeResolution];
    };
}

- (void)maskViewAction {
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }

    if (self.createRoomSettingView.superview) {
        [self.createRoomSettingView removeFromSuperview];
        self.createRoomSettingView = nil;
    }

    if (self.qualityView.superview) {
        [self.qualityView removeFromSuperview];
        self.qualityView = nil;
    }
}

#pragma mark - Getter

- (LiveCreateRoomSettingView *)createRoomSettingView {
    if (!_createRoomSettingView) {
        _createRoomSettingView = [[LiveCreateRoomSettingView alloc] init];
        _createRoomSettingView.videoConfig = [LiveSettingVideoConfig defaultVideoConfig];
        _createRoomSettingView.delegate = self;
    }
    return _createRoomSettingView;
}

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
