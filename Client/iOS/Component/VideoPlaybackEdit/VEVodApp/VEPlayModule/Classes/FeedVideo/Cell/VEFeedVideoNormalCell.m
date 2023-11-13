// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEFeedVideoNormalCell.h"
#import "VESettingManager.h"
#import "VEVideoModel.h"
#import "UIColor+RGB.h"
#import "ToolKit.h"
#import "VEPlayerUIModule.h"
#import "VEInterfaceFeedBlockSceneConf.h"
#import "VEPlayerKit.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

#define VE_FEED_CELL_VIDEO_RATIO      (210.00 / 375.00)

#define VE_FEED_CELL_CONSTANT_HEIGHT      (68.0)

@interface VEFeedVideoNormalCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avaImgView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

@property (weak, nonatomic) IBOutlet UIImageView *playIconView;

@property (weak, nonatomic) IBOutlet UIView *centerContainerView;

@property (nonatomic, weak) VEVideoPlayerController *playerController;

@property (nonatomic, strong) VEInterface *playerControlInterface;

@property (nonatomic, assign) NSInteger currentPlayState;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerContainerHeightConstraint;

@end

@implementation VEFeedVideoNormalCell

- (void)dealloc {
    [self playerControlInterfaceDestory];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    

    self.avaImgView.layer.borderColor = [[UIColor veveod_colorWithRGB:0xD0D0D0 alpha:1.0] CGColor];
    self.centerContainerHeightConstraint.constant = VE_FEED_CELL_VIDEO_RATIO * UIScreen.mainScreen.bounds.size.width;
    [self layoutIfNeeded];
}

- (void)playerControlInterfaceDestory {
    [self.centerContainerView bringSubviewToFront:self.playIconView];
    self.playIconView.hidden = NO;
    [self.contentView bringSubviewToFront:self.playIconView];
    self.coverImgView.hidden = NO;
    [self.playerControlInterface removeFromSuperview];
    [self.playerControlInterface destory];
    self.playerControlInterface = nil;
}

- (void)cellDidEndDisplay:(BOOL)force {
    if (force) {
        [self playerControlInterfaceDestory];
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    } else {
        [self.playerController pause];
    }
}

- (BOOL)isPlaying {
    return [self.playerController isPlaying];
}


#pragma mark ----- Variable Setter & Getter

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    self.titleLabel.text =  [NSString stringWithFormat:@"%@", self.videoModel.title];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ · %@", [self.videoModel playTimeToString], self.videoModel.createTime];
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl]];
}

+ (CGFloat)cellHeight:(VEVideoModel *)videoModel {
    return (UIScreen.mainScreen.bounds.size.width * VE_FEED_CELL_VIDEO_RATIO) + VE_FEED_CELL_CONSTANT_HEIGHT;
}

#pragma mark - Button Action

- (IBAction)shareTouchUpInsideAction:(id)sender {
    [DeviceInforTool share];
}

- (IBAction)reportTouchUpInsideAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(feedVideoCellReport:)]) {
        [self.delegate feedVideoCellReport:self];
    }
}

#pragma mark ----- Play

- (void)startPlay {
    [self centerViewTouchUpInsideAction:nil];
}

- (IBAction)centerViewTouchUpInsideAction:(id)sender {
    self.playIconView.hidden = YES;
    self.coverImgView.hidden = YES;
    [self createPlayer];
    [self playerStart];
}

- (void)createPlayer {
    if ([self.delegate respondsToSelector:@selector(feedVideoCellShouldPlay:)]) {
        self.playerController = (VEVideoPlayerController *)[self.delegate feedVideoCellShouldPlay:self];
        [self.centerContainerView addSubview:self.playerController.view];
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.centerContainerView);
        }];
        [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
        [self createPlayerControl];
    }
}

- (void)createPlayerControl {
    self.playerControlInterface = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceFeedBlockSceneConf new]];
    [self.centerContainerView addSubview:self.playerControlInterface];
    [self.playerControlInterface mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.centerContainerView);
    }];
}

- (void)playerStart {
    if (self.playerController.isPlaying || self.playerController.isPause) {
        [self.playerController play];
    } else {
        [self playerOptions];
        [self.playerController playWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
    }
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


@end
