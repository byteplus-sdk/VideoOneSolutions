// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullUIViewController.h"
#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <ToolKit/Localizator.h>
@interface VELPullUIViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) VELSettingsCollectionView *controlView;
@property (nonatomic, strong) VELSettingsButtonViewModel *basicViewModel;
@property (nonatomic, strong) VELSettingsButtonViewModel *avViewModel;
@property (nonatomic, strong, readwrite) UIView *controlContainer;
@property (nonatomic, strong, readwrite) UIView *playerContainer;
@property (nonatomic, strong) VELSettingsButtonViewModel *currentPopObj;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@end

@implementation VELPullUIViewController
- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithConfig:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithConfig:nil];
}

- (instancetype)initWithConfig:(VELPullSettingConfig *)config {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _config = [config mutableCopy];
        _config.urlType = VELPullUrlTypeMain;
        _autoPlayWhenLoaded = YES;
        _autoHidePlayerView = YES;
    }
    return self;
}

- (void)resetConfig:(VELPullSettingConfig *)config {
    _config = [config mutableCopy];
    _config.urlType = VELPullUrlTypeMain;
}

- (void)dealloc {
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    [self destroyPlayer];
    [VELUIToast hideAllToast];
}

- (void)setupReachability {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(networkStatusDidChanged:)
                                               name:@"VELNetworkReachabilityStatusChanged"
                                             object:nil];
}

- (void)networkStatusDidChanged:(NSNotification *)noti {
    NSInteger status = [[noti.userInfo objectForKey:@"status"] integerValue];
    if (status == 1 || status == 2) {
        [self playWithNetworkReachable];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    self.view.backgroundColor = UIColor.blackColor;
    self.shouldPlayInBackground = YES;
    self.isFirstAppear = YES;
    [self setupUI];
    [self setupReachability];
    self.playerContainer.hidden = self.isPreLoading || self.isAutoHidePlayerView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideCycleInfo];
    [self hideCallbackNote];

}

- (BOOL)shouldPopViewController:(BOOL)isGesture {
    if ([self isPlaying]) {
        if (isGesture) {
            return NO;
        }
        [self exitPlayback];
        return NO;
    } else {
        return YES;
    }
}

- (void)exitPlayback {
    [self destroyPlayer];
    [self vel_hideCurrentViewControllerWithAnimated:YES];
}

- (void)setupUI {
    [self.navigationBar onlyShowLeftBtn];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.navigationBar.leftButton setImage:VELUIImageMake(@"ic_close_white") forState:(UIControlStateNormal)];
    
    self.playerContainer = [[UIView alloc] init];
    self.playerContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerContainer];
    [self.playerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.controlContainer = [[UIView alloc] init];
    self.controlContainer.backgroundColor = [UIColor clearColor];
    __weak __typeof__(self)weakSelf = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self hideAllSettingsView];
    }];
    tapGesture.delegate = self;
    [self.controlContainer addGestureRecognizer:tapGesture];
    [self.view addSubview:self.controlContainer];
    [self.controlContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view bringSubviewToFront:self.navigationBar];
    
    
    [self.controlContainer addSubview:self.controlView];
    [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGSize controlSize = CGSizeMake(56, 94);
        make.size.mas_greaterThanOrEqualTo(controlSize);
        if (@available(iOS 11.0, *)) {
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).mas_offset(-10);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-30);
        } else {
            make.right.equalTo(self.view).mas_offset(-10);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop).mas_offset(-30);
        }
    }];
}

- (void)setupVolumeSlider {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 10, 10)];
    UISlider *volumeSlider = nil;
    volumeView.clipsToBounds = YES;
    [self.view addSubview:volumeView];
    
    for (UIView *view in [volumeView subviews]){
        if ([[view.class description] isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }
    _volumeSlider = volumeSlider;
}

- (void)hideAllSettingsView {
    [self _hideBasicSetting];
    [self _hideAVSetting];
}

- (void)_showBasicSetting {
    if (self.currentPopObj != nil && self.basicViewModel != self.currentPopObj) {
        [self hideAllSettingsView];
    }
    self.currentPopObj = self.basicViewModel;
    [self showBasicSetting];
}

- (void)_hideBasicSetting {
    [self hideBasicSetting];
    if (self.currentPopObj == self.basicViewModel) {
        self.currentPopObj = nil;
    }
}

- (VELSettingsButtonViewModel *)basicViewModel {
    if (!_basicViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _basicViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_play_basic_setting", @"MediaLive") actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (![self isBasicSettingShowing]) {
                [self _showBasicSetting];
            } else {
                [self _hideBasicSetting];
            }
        }];
    }
    return _basicViewModel;
}


- (void)_showAVSetting {
    if (self.currentPopObj != nil && self.avViewModel != self.currentPopObj) {
        [self hideAllSettingsView];
    }
    self.currentPopObj = self.avViewModel;
    [self showAVSetting];
}

- (void)_hideAVSetting {
    [self hideAVSetting];
    if (self.currentPopObj == self.avViewModel) {
        self.currentPopObj = nil;
    }
}

- (VELSettingsButtonViewModel *)avViewModel {
    if (!_avViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _avViewModel = [self buttonModelWithTitle:LocalizedStringFromBundle(@"medialive_play_av_setting", @"MediaLive") actionBlock:^(VELSettingsButtonViewModel *model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (![self isAVSettingShowing]) {
                [self _showAVSetting];
            } else {
                [self _hideAVSetting];
            }
        }];
    }
    return _avViewModel;
}


- (VELSettingsButtonViewModel *)buttonModelWithTitle:(NSString *)title
                                       actionBlock:(void (^)(VELSettingsButtonViewModel *model, NSInteger index))actionBlock {
    VELSettingsButtonViewModel *model = [VELSettingsButtonViewModel modelWithTitle:title];
    model.useCellSelect = NO;
    model.size = CGSizeMake(VELAutomaticDimension, 42);
    model.cornerRadius = 3;
    model.titleAttributes[NSForegroundColorAttributeName] = UIColor.blackColor;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    paraStyle.lineHeightMultiple = 1.2;
    paraStyle.alignment = NSTextAlignmentCenter;
    model.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.titleAttributes[NSParagraphStyleAttributeName] = [paraStyle mutableCopy];
    model.selectTitleAttributes[NSForegroundColorAttributeName] = UIColor.blackColor;
    model.selectTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    model.selectTitleAttributes[NSParagraphStyleAttributeName] = [paraStyle mutableCopy];
    model.backgroundColor = UIColor.clearColor;
    model.selectedBlock = actionBlock;
    model.containerBackgroundColor = UIColor.whiteColor;
    model.containerSelectBackgroundColor = UIColor.whiteColor;
    return model;
}

- (VELSettingsCollectionView *)controlView {
    if (!_controlView) {
        _controlView = [[VELSettingsCollectionView alloc] init];
        _controlView.backgroundColor = [UIColor clearColor];
        _controlView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _controlView.itemMargin = 10;
        _controlView.allowSelection = YES;
        _controlView.layoutMode = VELCollectionViewLayoutModeLeft;
        _controlView.models = @[self.basicViewModel, self.avViewModel];
    }
    return _controlView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.controlContainer) {
        if (self.currentPopObj != nil) {
            [self hideAllSettingsView];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm:ss.SSS";
    }
    return _dateFormatter;
}

- (void)setShouldPlayInBackground:(BOOL)shouldPlayInBackground {
    _shouldPlayInBackground = shouldPlayInBackground;
    if (shouldPlayInBackground) {
        [VELDeviceHelper setPlaybackAudioSessionWithOptions:(AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker)];
    } else {
        [VELDeviceHelper setPlaybackAudioSessionWithOptions:(AVAudioSessionCategoryOptionDefaultToSpeaker)];
    }
}
@end
