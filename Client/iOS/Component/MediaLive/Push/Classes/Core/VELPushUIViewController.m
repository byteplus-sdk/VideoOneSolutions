// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushUIViewController+Private.h"
#import "VELPreviewSizeManager.h"
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>
@implementation VELPushUIViewController

- (instancetype)initWithConfig:(VELPushSettingConfig *)config {
    if (self = [super initWithNibName:nil bundle:nil]) {
        if (config == nil) {
            self.config = [[VELSettingConfig sharedConfig] getPushSettingConfigWithCaptureType:(VELSettingCaptureTypeInner)];
        } else {
            self.config = [config mutableCopy];
        }
    }
    return self;
}

- (instancetype)initWithCaptureType:(VELSettingCaptureType)captureType {
    VELPushSettingConfig *cfg = [[VELSettingConfig sharedConfig] getPushSettingConfigWithCaptureType:captureType];
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.config = cfg;
        self.config.captureType = captureType;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithConfig:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithConfig:nil];
}

- (void)dealloc {
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    [self destoryEngine];
    [VELPixelBufferManager releaseMemory];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [self.config setupUrlsWithString:self.config.originUrlString];
    [self setupUI];
    [self changeControlIsHidden:YES];
    [VELUIToast setTemporaryLoadingShowView:self.previewContainer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [VELUIToast setTemporaryLoadingShowView:self.previewContainer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startEngineAndPreview];
    [self changeControlIsHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEngineAndPreview];
    [self changeControlIsHidden:YES];
}

- (void)setupUI {
    [self setupPreviewContainer];
    [self setupNetworkQualityView];
    [self setupRotateVisualView];
    [self setupControlContainerView];
    [self setupPopControlView];
    [self setupUIForNotStreaming];
}

- (void)startEngineAndPreview {
    if (self.isStartEngineAndPreview) {
        return;
    }
    [self setupEngine];
    [self startVideoCapture];
    [self startAudioCapture];
    [self startPreivew];
    self.isStartEngineAndPreview = YES;
    [self attemptToCurrentDeviceOrientation];
    [[VELPreviewSizeManager shareInstance] updateViewWidth:self.view.vel_width
                                                viewHeight:self.view.vel_height
                                              previewWidth:self.config.captureSize.width
                                             previewHeight:self.config.captureSize.height
                                                 fitCenter:NO];
    if (self.isSupportEffect) {
        [self setupEffectManager];
    }
}

- (void)stopEngineAndPreview {
    if (!self.isStartEngineAndPreview) {
        return;
    }
    [self resetSettingView];
    self.isStartEngineAndPreview = NO;
    [self destoryAllAdditionMemoryObjects];
    [self destoryEngine];
}


- (void)changeControlIsHidden:(BOOL)hidden {
    if (!self.isStreaming) {
        self.startPushBtn.hidden = hidden;
        self.previewControl.hidden = hidden;
    }
    if (hidden) {
        [self hideAllPopView];
    }
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    [self.navigationBar onlyShowLeftBtn];
    self.navigationBar.hidden = YES;
    self.navigationBar.titleLabel.hidden = YES;
    self.navigationBar.titleLabel.textColor = UIColor.whiteColor;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.navigationBar.leftButton setImage:VELUIImageMake(@"ic_close_white") forState:(UIControlStateNormal)];
}

- (void)setupPreviewContainer {
    self.previewContainer = [[UIView alloc] init];
    self.previewContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.previewContainer];
    [self.previewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNetworkQualityView {
    [self.view addSubview:self.netQualityView];
    [self.netQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom).mas_offset(15);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).mas_offset(20);
        } else {
            make.left.equalTo(self.view).mas_offset(20);
        }
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
}

- (void)setupRotateVisualView {
    self.rotateVisualView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
    self.rotateVisualView.hidden = YES;
    [self.view addSubview:self.rotateVisualView];
    [self.rotateVisualView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupControlContainerView {
    self.controlContainerView = [[UIView alloc] init];
    [self setupDeviceGesture];
    
    self.controlContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.controlContainerView];
    [self.controlContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupPopControlView {
    self.popControlView = [[_VELPushUIPopControlView alloc] init];
    self.popControlView.backgroundColor = [UIColor clearColor];
    self.popControlView.clipsToBounds = YES;
    [self.controlContainerView addSubview:self.popControlView];
}

- (void)destoryAllAdditionMemoryObjects {
    self.micViewModel.isSelected = NO;
    [self.micViewModel updateUI];
}
- (BOOL)checkConfigIsValid {
    if (!self.config.isValid) {
        [self showPreviewSettings];
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_push_adress_error", @"MediaLive") detailText:@""];
        return NO;
    }
    if ([self.config checkShouldTipBitrateBugFix]) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_abr_system_bug_toast", @"MediaLive") detailText:@""];
        [self showPreviewSettings];
        return NO;
    }
    return YES;
}

- (void)backButtonClick {
    [super backButtonClick];
    [self hideAllPopView];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self hideAllPopView];
    BOOL landSpace = (size.width > size.height);
    self.navigationBar.topSafeMargin = [VELDeviceHelper safeAreaInsets].top;
    [self.navigationBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VEL_NAVIGATION_HEIGHT);
    }];
    if (self.isStreaming) {
        [self setupUIForStreamingLandspace:landSpace force:YES];
    } else {
        [self setupUIForNotStreamingLandSpace:landSpace force:YES];
    }
}
- (BOOL)shouldPopViewController:(BOOL)isGesture {
    if ([self isStreaming]) {
        if (isGesture) {
            return NO;
        }
        [self exitStreaming];
        return NO;
    } else if (self.currentPopObj != nil && isGesture) {
        return NO;
    }
    return YES;
}

- (CGSize)captureSize {
    return self.config.captureSize;
}

- (CGSize)outputSize {
    return self.config.encodeSize;
}
- (void)exitStreaming {
    [self restartEngine];
    [self setupUIForNotStreaming];
}

- (VELUIButton *)startPushBtn {
    if (!_startPushBtn) {
        _startPushBtn = [[VELUIButton alloc] init];
        _startPushBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_startPushBtn setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _startPushBtn.cornerRadius = 24;
        _startPushBtn.backgroundColor = VELColorWithHex(0x2C5BF6);
        [_startPushBtn setTitle:LocalizedStringFromBundle(@"medialive_start_push", @"MediaLive") forState:(UIControlStateNormal)];
        [_startPushBtn addTarget:self action:@selector(startStreaming) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _startPushBtn;
}
@end

