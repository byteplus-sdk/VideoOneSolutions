// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushSettingViewController.h"
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import "VELPushSettingViewModelTool.h"
#import "VELSettingsCollectionView.h"
#import "VELSettingConfig.h"
#import <ToolKit/Localizator.h>
@interface VELPushSettingViewController ()
@property(nonatomic, copy) void (^completionBlock)(VELPushSettingViewController *vc, VELPushSettingConfig *config);
@property (nonatomic, strong) NSMutableArray <__kindof VELSettingsBaseViewModel *> *settingModels;
@property (nonatomic, strong) VELSettingsCollectionView *settingCollectionView;
@property (nonatomic, strong) VELPushSettingViewModelTool *modelTool;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContainer;
@property (nonatomic, strong) UIView *container;
@end

@implementation VELPushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.pushConfig == nil) {
        self.pushConfig = self.modelTool.config;
    } else {
        self.modelTool.config = self.pushConfig;
    }
    self.showNavigationBar = NO;
    [self setupContainer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showContainer];
}

- (void)showContainer {
    if (self.container.isHidden) {
        self.container.hidden = NO;
        self.container.alpha = 0;
        self.view.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1;
            self.container.alpha = 1;
            [self layoutContainerWithShow:YES];
        }];
    }
}

- (void)showFromVC:(nullable UIViewController *)vc
        completion:(void (^)(VELPushSettingViewController *vc, VELPushSettingConfig *config))completion; {
    vc = vc ?: UIApplication.sharedApplication.keyWindow.rootViewController;
    if (vc.parentViewController) {
        vc = vc.parentViewController;
    }
    vc.definesPresentationContext = YES;
    self.completionBlock = completion;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    if (![vc.presentedViewController isKindOfClass:VELQRScanViewController.class]) {
        [vc presentViewController:self animated:NO completion:nil];
    }
    self.showing = YES;
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
        self.container.alpha = 0;
        [self layoutContainerWithShow:NO];
    } completion:^(BOOL finished) {
        self.container.hidden = YES;
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        self.showing = NO;
        if (self.completionBlock) {
            self.completionBlock(self, self.pushConfig);
        }
    }];
}

- (void)setPushConfig:(VELPushSettingConfig *)pushConfig {
    _pushConfig = pushConfig;
    self.modelTool.config = pushConfig;
    if (self.isViewLoaded) {
        [self setupSettingsModels];
    }
}

- (void)layoutContainerWithShow:(BOOL)show {
    [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollContainer);
        if (show) {
            make.bottom.equalTo(self.scrollContainer);
        } else {
            make.top.equalTo(self.scrollContainer.mas_bottom);
        }
        make.height.mas_equalTo(self.view).multipliedBy(0.6);
    }];
    [self.scrollContainer setNeedsLayout];
    [self.scrollContainer layoutIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self.settingCollectionView reloadData];
}

- (void)setupContainer {
    self.scrollContainer = [[UIView alloc] init];
    __weak __typeof__(self)weakSelf = self;
    [self.scrollContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self hide];
    }]];
    
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.bottom.equalTo(self.view);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    [self.scrollView addSubview:self.scrollContainer];
    [self.scrollContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.size.equalTo(self.scrollView);
    }];
    [self.scrollContainer addSubview:self.container];
    [self layoutContainerWithShow:NO];
    [self setupContainerSubUI];
    [self setupSettingsModels];
    [self setupActions];
    [self.container setNeedsLayout];
    [self.container layoutIfNeeded];
}

- (void)setupActions {
    
}

- (void)setupSettingsModels {
    if (!self.settingModels) {
        self.settingModels = [NSMutableArray arrayWithCapacity:10];
    } else {
        [self.settingModels removeAllObjects];
    }
    [self setupPushSettingModels];
    self.settingCollectionView.models = self.settingModels;
}

- (void)setupPushSettingModels {
    VELSettingCaptureType captureType = self.pushConfig.captureType;
    if (captureType == VELSettingCaptureTypeScreen) {
        
        [self.settingModels addObject:self.modelTool.encodeResolutionAndScreenViewModel];
        [self.settingModels addObject:self.modelTool.encodeFPSViewModel];
        
        [self.settingModels addObject:self.modelTool.fixScreenCaptureVideoAudioDiffViewModel];
        
        [self setupDelegateCallback];
        return;
    }
    BOOL innerCapture = captureType == VELSettingCaptureTypeInner;
    BOOL hasVideoEncode = captureType != VELSettingCaptureTypeAudioOnly;
    
    if (innerCapture) {
        [self.settingModels addObject:self.modelTool.captureResolutionViewModel];
        [self.settingModels addObject:self.modelTool.captureFPSViewModel];
    }
    
    if (hasVideoEncode) {
        [self.settingModels addObject:self.modelTool.encodeResolutionViewModel];
        [self.settingModels addObject:self.modelTool.encodeFPSViewModel];
    }
    [self.settingModels addObject:self.modelTool.enableAutoBitrateViewModel];
    [self.settingModels addObject:self.modelTool.renderModeViewModel];
    
    [self setupDelegateCallback];
}

- (void)setupDelegateCallback {
    __weak __typeof__(self)weakSelf = self;
    VELMenuSelectedBlock oldBlock = self.modelTool.renderModeViewModel.menuSelectedBlock;
    [self.modelTool.renderModeViewModel setMenuSelectedBlock:^BOOL(NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pushSetting:onRenderModeChanged:)]) {
            NSInteger renderMode = [self.modelTool.renderModeViewModel.menuValues[index] integerValue];
            [self.delegate pushSetting:self onRenderModeChanged:renderMode];
        }
        if (oldBlock) {
            return oldBlock(index);
        }
        return NO;
    }];
}

- (void)setupContainerSubUI {
    UIView *header = [[UIView alloc] init];
    VELNavigationBar *navBar = [VELNavigationBar navigationBarWithTitle:LocalizedStringFromBundle(@"medialive_setting", @"MediaLive")];
    navBar.topSafeMargin = 3;
    navBar.bottomLine.hidden = NO;
    navBar.titleLabel.textColor = UIColor.whiteColor;
    navBar.titleLabel.font = [UIFont systemFontOfSize:16];
    [navBar onlyShowTitle];
    navBar.backgroundColor = UIColor.clearColor;
    [header addSubview:navBar];
    [navBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(header);
        make.height.mas_equalTo(30);
    }];
    
    VELSettingsInputViewModel *inputModel = self.modelTool.inputViewModel;
    UIView *settingView = inputModel.settingView;
    settingView.backgroundColor = UIColor.clearColor;
    [header addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navBar.mas_bottom).mas_offset(8);
        make.left.bottom.right.equalTo(header);
    }];
    
    [self.container addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.container);
        make.height.mas_equalTo(100);
    }];
    
    self.settingCollectionView.backgroundColor = UIColor.clearColor;
    [self.container addSubview:self.settingCollectionView];
    [self.settingCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header.mas_bottom).mas_offset(5);
        make.left.equalTo(self.container).mas_offset(16);
        make.right.equalTo(self.container).mas_offset(-16);
        make.bottom.equalTo(self.container);
    }];
}

- (VELSettingsCollectionView *)settingCollectionView {
    if (!_settingCollectionView) {
        _settingCollectionView = [[VELSettingsCollectionView alloc] init];
        _settingCollectionView.backgroundColor = UIColor.clearColor;
        _settingCollectionView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _settingCollectionView.layoutMode = VELCollectionViewLayoutModeCenter;
        _settingCollectionView.itemMargin = 8;
    }
    return _settingCollectionView;
}

- (VELPushSettingViewModelTool *)modelTool {
    if (!_modelTool) {
        _modelTool = [[VELPushSettingViewModelTool alloc] init];
    }
    return _modelTool;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.layer.cornerRadius = 16;
        _container.backgroundColor = [UIColor clearColor];
        _container.hidden = YES;
        _container.layer.masksToBounds = YES;
        if (@available(iOS 11.0, *)) {
            _container.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        }
        UIVisualEffectView *effect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
        [_container addSubview:effect];
        [effect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_container);
        }];
    }
    return _container;
}
@end
