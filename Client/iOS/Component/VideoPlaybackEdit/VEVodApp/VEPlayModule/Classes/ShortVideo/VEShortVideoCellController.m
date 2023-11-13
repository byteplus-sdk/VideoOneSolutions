// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEShortVideoCellController.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/ReportComponent.h>
#import <Masonry/Masonry.h>
#import "VEPlayerUIModule.h"
#import "VEInterfaceSimpleMethodSceneConf.h"
#import "VEPlayerKit.h"
#import "VEGradientView.h"

@interface VEShortVideoMaskView : VEGradientView

typedef NS_ENUM(NSInteger, MaskViewType) {
    MaskViewTypeTop = 0,
    MaskViewTypeBottom,
};

@end

@implementation VEShortVideoMaskView

- (instancetype)initWithType:(MaskViewType)type {
    self = [super init];
    if (self) {
        if (type == MaskViewTypeBottom) {
            UIColor *startColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.0 * 255];
            UIColor *middleColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.3 * 255];
            UIColor *endColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];
            self.gradientLayer.colors = @[(id)startColor.CGColor, (id)middleColor.CGColor, (id)endColor.CGColor];
            self.gradientLayer.startPoint = CGPointMake(0.5, 0);
            self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        } else {
            UIColor *startColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.3 * 255];
            UIColor *middleColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.1157 * 255];
            UIColor *endColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0 * 255];
            self.gradientLayer.colors = @[(id)startColor.CGColor, (id)middleColor.CGColor, (id)endColor.CGColor];
            self.gradientLayer.startPoint = CGPointMake(0.5, 0);
            self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        }
    }
    return self;
}

@end


@interface VEShortVideoCellController () <VEInterfaceDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) VEInterface *playerControlInterface;
@property (nonatomic, strong) VEShortVideoMaskView *topMaskView;
@property (nonatomic, strong) VEShortVideoMaskView *bottomMaskView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation VEShortVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self playerStop];
}

#pragma mark - Publish Action

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    
    self.titleLabel.text = videoModel.title;
    self.subtitleLabel.text = videoModel.subTitle;
}


- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [ReportComponent report:self.videoModel.videoId cancelHandler:nil completion:nil];
    }
}


#pragma mark ----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playerCover];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self playerStop];
}


#pragma mark ----- Play

- (void)playerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    [self createPlayerControl];
    [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
}

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    if (self.playerController.isPause) {
        [self.playerController play];
        return;
    }
    [self createPlayer];
    [self createPlayerControl];
    [self playerOptions];
    [self.playerController setMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
    [self.playerController setLooping:YES];
    [self.playerController play];
}

- (void)playerStop {
    @autoreleasepool {
        [self.playerControlInterface destory];
        self.playerControlInterface = nil;
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

#pragma mark - VEPageItem

- (void)prepareToPlay {
    [self playerCover];
}

- (void)play {
    [self playerStart];
}

- (void)pause {
    [self.playerController pause];
}

- (void)stop {
    [self playerStop];
}

#pragma mark ----- Player

- (void)createPlayer {
    if (self.playerController) {
        return;
    }
    self.playerController = [[VEVideoPlayerController alloc] initWithType:VEVideoPlayerTypeShort];
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    [self.view bringSubviewToFront:self.playerController.view];
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)createPlayerControl {
    if (self.playerControlInterface) {
        return;
    }
    self.playerControlInterface = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceSimpleMethodSceneConf new]];
    self.playerControlInterface.delegate = self;
    [self.view addSubview:self.playerControlInterface];
    [self.playerControlInterface mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.playerControlInterface addSubview:self.topMaskView];
    [self.topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.playerControlInterface);
        make.height.mas_equalTo(200);
    }];
    
    [self.playerControlInterface addSubview:self.bottomMaskView];
    [self.playerControlInterface sendSubviewToBack:self.bottomMaskView];
    [self.bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.playerControlInterface);
        make.height.mas_equalTo(200);
    }];
    
    [self.playerControlInterface addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.width.mas_equalTo(SCREEN_WIDTH * 0.73);
    }];
    
    [self.playerControlInterface addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.equalTo(self.subtitleLabel.mas_top).offset(-6);
        make.width.equalTo(self.subtitleLabel);
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.playerControlInterface addGestureRecognizer:longPress];
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
    
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    self.playerController.h265Open = h265.open;
    
    VESettingModel *hardwareDecode = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode];
    self.playerController.hardwareDecodeOpen = hardwareDecode.open;
}


#pragma mark ----- VEInterfaceDelegate

- (void)interfaceShouldEnableSlide:(BOOL)enable {
    if ([self.delegate respondsToSelector:@selector(shortVideoController:shouldLockVerticalScroll:)]) {
        [self.delegate shortVideoController:self shouldLockVerticalScroll:enable];
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.tag = 3001;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.tag = 3002;
        _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

- (VEShortVideoMaskView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [[VEShortVideoMaskView alloc] initWithType:MaskViewTypeTop];
    }
    return _topMaskView;
}

- (VEShortVideoMaskView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[VEShortVideoMaskView alloc] initWithType:MaskViewTypeBottom];
    }
    return _bottomMaskView;
}



@end
