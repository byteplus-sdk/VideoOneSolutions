// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCreateRoomViewController.h"
#import "BytedEffectProtocol.h"
#import "LiveCountdownView.h"
#import "LiveCreateRoomControlView.h"
#import "LiveCreateRoomHostInfoView.h"
#import "LiveCreateRoomTipView.h"
#import "LiveRTCManager.h"
#import "LiveRoomSettingComponent.h"
#import "LiveRoomViewController.h"

@interface LiveCreateRoomViewController () <LiveCreateRoomControlViewDelegate>
@property (nonatomic, strong) LiveCountdownView *countdownView;
@property (nonatomic, strong) LiveCreateRoomTipView *tipView;
@property (nonatomic, strong) LiveCreateRoomHostInfoView *hostInfo;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) LiveCreateRoomControlView *controlView;
@property (nonatomic, strong) LiveRoomSettingComponent *settingComponent;
@property (nonatomic, strong) BytedEffectProtocol *beautyComponent;

@property (nonatomic, strong) LiveRoomInfoModel *roomInfoModel;
@property (nonatomic, copy) NSString *pushUrl;

@end

@implementation LiveCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#272E3B"];
    self.navView.backgroundColor = [UIColor clearColor];
    self.navLeftImage = [UIImage imageNamed:@"interactive_live_close" bundleName:HomeBundleName];
    [self loadDataWithCreateLive];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)startButtonAction:(UIButton *)sender {
    self.controlView.hidden = YES;
    self.startButton.hidden = YES;
    self.hostInfo.hidden = YES;
    self.tipView.hidden = YES;
    self.navView.hidden = YES;
    [PublicParameterComponent share].roomId = self.roomInfoModel.roomID;
    __weak __typeof(self) wself = self;
    [self.countdownView start:^{
        __strong __typeof(wself) sself = wself;
        [LiveRTSManager liveStartLive:sself.roomInfoModel.roomID block:^(LiveUserModel *_Nullable hostUserModel, RTSACKModel *_Nonnull model) {
            if (model.result) {
                sself.controlView.hidden = NO;
                sself.startButton.hidden = NO;
                sself.hostInfo.hidden = NO;
                sself.tipView.hidden = NO;
                sself.navView.hidden = NO;
                [sself.countdownView removeFromSuperview];
                sself.roomInfoModel.hostUserModel = hostUserModel;

                LiveRoomViewController *next = [[LiveRoomViewController alloc]
                    initWithRoomModel:wself.roomInfoModel
                        streamPushUrl:wself.pushUrl];
                [sself.navigationController pushViewController:next animated:NO];
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"start_live_title")];
            } else {
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    }];
}

#pragma mark - Private Action
- (void)leftButtonOtherAction {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.hangUpBlock) {
        self.hangUpBlock();
    }
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.renderView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view bringSubviewToFront:self.navView];

    [self.view addSubview:self.hostInfo];
    [self.hostInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.size.mas_equalTo(CGSizeMake(295, 68));
        make.centerY.equalTo(self.navView.mas_bottom).offset(30);
    }];
    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.hostInfo);
        make.top.mas_equalTo(self.hostInfo.mas_bottom).offset(6);
    }];

    [self.view addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(170, 50));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
    }];

    [self.view addSubview:self.controlView];
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.startButton.mas_top).offset(-10);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(85);
    }];

    [self.view addSubview:self.countdownView];
    [self.countdownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)loadDataWithCreateLive {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveCreateLive:[LocalUserComponent userModel].name
                             block:^(LiveRoomInfoModel *roomInfoModel, LiveUserModel *hostUserModel, NSString *pushUrl, RTSACKModel *model) {
                                 [[ToastComponent shareToastComponent] dismiss];
                                 if (model.result) {
                                     wself.roomInfoModel = roomInfoModel;
                                     wself.pushUrl = pushUrl;
                                     [wself addSubviewAndConstraints];
                                     [wself setupLocalRenderView];
                                     [wself.beautyComponent reset];
                                 } else {
                                     AlertActionModel *alertModel = [[AlertActionModel alloc] init];
                                     alertModel.title = LocalizedString(@"ok");
                                     alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
                                         if ([action.title isEqualToString:LocalizedString(@"ok")]) {
                                             [wself.navigationController popViewControllerAnimated:YES];
                                         }
                                     };
                                     [[AlertActionManager shareAlertActionManager] showWithMessage:model.message actions:@[alertModel]];
                                 }
                             }];
}
- (void)setupLocalRenderView {
    [[LiveRTCManager shareRtc] switchVideoCapture:YES];
    [[LiveRTCManager shareRtc] switchAudioCapture:YES];

    UIView *rtcStreamView = [[LiveRTCManager shareRtc] bindCanvasViewToUid:[LocalUserComponent userModel].uid];
    rtcStreamView.hidden = NO;
    [self.renderView addSubview:rtcStreamView];
    [rtcStreamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.renderView);
    }];

    // add effect
    [self.beautyComponent resume];
}

#pragma mark - LiveCreateRoomControlViewDelegate
- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedSwitchCameraButton:(UIButton *)button {
    [[LiveRTCManager shareRtc] switchCamera];
}
- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedBeautyButton:(UIButton *)button {
    if (self.beautyComponent) {
        __weak __typeof(self) wself = self;
        self.controlView.hidden = YES;
        [self.beautyComponent showWithView:self.view
                              dismissBlock:^(BOOL result) {
                                  wself.controlView.hidden = NO;
                              }];
    }
}
- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedSettingButton:(UIButton *)button {
    [self.settingComponent show];
}

#pragma mark - Getter

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        _startButton.backgroundColor = [UIColor colorFromHexString:@"#4080FF"];
        UIColor *startColor = [UIColor colorFromHexString:@"#FF1764"];
        UIColor *endColor = [UIColor colorFromRGBHexString:@"#ED3596"];
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0, 0, 259, 52);
        gradientLayer.colors = @[(__bridge id)[startColor colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[endColor colorWithAlphaComponent:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        [_startButton.layer addSublayer:gradientLayer];
        [_startButton setTitle:LocalizedString(@"go_live") forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        [_startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _startButton.layer.cornerRadius = 25;
        _startButton.layer.masksToBounds = YES;
    }
    return _startButton;
}

- (LiveCreateRoomTipView *)tipView {
    if (!_tipView) {
        _tipView = [[LiveCreateRoomTipView alloc] init];
        _tipView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _tipView.message = [NSString stringWithFormat:LocalizedString(@"application_experiencing_%@_title"), @"20"];
        _tipView.layer.cornerRadius = 8;
    }
    return _tipView;
}

- (LiveCreateRoomHostInfoView *)hostInfo {
    if (!_hostInfo) {
        _hostInfo = [[LiveCreateRoomHostInfoView alloc] init];
        _hostInfo.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _hostInfo.layer.cornerRadius = 8;
    }
    return _hostInfo;
}

- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (LiveCreateRoomControlView *)controlView {
    if (!_controlView) {
        _controlView = [[LiveCreateRoomControlView alloc] init];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (LiveRoomSettingComponent *)settingComponent {
    if (!_settingComponent) {
        _settingComponent = [[LiveRoomSettingComponent alloc] initWithView:self.view];
    }
    return _settingComponent;
}

- (BytedEffectProtocol *)beautyComponent {
    if (!_beautyComponent) {
        _beautyComponent = [[BytedEffectProtocol alloc] initWithEngine:[LiveRTCManager shareRtc].rtcEngineKit withType:EffectTypeRTC useCache:NO];
    }
    return _beautyComponent;
}

- (LiveCountdownView *)countdownView {
    if (!_countdownView) {
        _countdownView = [[LiveCountdownView alloc] init];
    }
    return _countdownView;
}

- (void)dealloc {
    [[LiveRTCManager shareRtc] leaveLiveRoom];
}

@end
