// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TTLiveCellController.h"
#import "TTMixModel.h"
#import "TTLiveModel.h"
#import "LiveFeedViewController.h"
#import "TTLivePlayerManager.h"
#import "TTLivePlayerController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/VEInterfaceFactory.h>

@interface TTLiveCellController ()

@property (nonatomic, strong) UIView *renderView;

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIView *statusView;

@property (nonatomic, strong) UIButton *enterRoomBtn;

@property (nonatomic, strong) TTLivePlayerController *player;

@end

@implementation TTLiveCellController
@synthesize reuseIdentifier;

#pragma mark -- system method override
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self initUI];
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark -- private method
- (void)initUI {
    [self.view addSubview:self.renderView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.renderView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.renderView);
    }];
    
    [self.view addSubview:self.enterRoomBtn];
    [self.enterRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(204, 36));
        make.left.equalTo(self.view).offset(86);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-238);
    }];
    
    [self.view addSubview:self.statusView];
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-121);
        make.size.mas_equalTo(CGSizeMake(78, 20));
    }];
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusView);
        make.top.equalTo(self.statusView.mas_bottom).offset(8);
        make.right.equalTo(self.view).offset(-12);
    }];
    
    [self.view addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.right.equalTo(self.titleLabel);
    }];
}
- (void)enterLiveRoom {
    [[TTLivePlayerManager sharedLiveManager] recoveryAllPlayerWithException:self.player];
    LiveFeedViewController *liveFeedVC = [[LiveFeedViewController alloc] initWithLiveModel:self.mixModel.liveModel];
    [self.navigationController pushViewController:liveFeedVC animated:NO];
}

#pragma mark -- TTPageItem

- (void)itemDidLoad {
    VOLogI(VOTTProto, @"itemDidLoad");
    self.player = [[TTLivePlayerManager sharedLiveManager] createLivePlayer];
    [self.player bindStreamView:self.renderView];
}

- (void)itemDidRemoved {
    VOLogI(VOTTProto, @"itemDidRemoved");
    [[TTLivePlayerManager sharedLiveManager] recoveryPlayer:self.player];
    self.player = nil;
}

- (void)partiallyShow {
    VOLogI(VOTTProto, @"partiallyShow");
    if (self.player) {
        [self.player bindStreamView:self.renderView];
        [self.player playerStreamWith:self.mixModel.liveModel];
        [self.player setMute:YES];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
}

- (void)completelyShow {
    VOLogI(VOTTProto, @"completelyShow");
    if (self.player) {
        [self.player playerStreamWith:self.mixModel.liveModel];
        [self.player setMute:NO];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
}

- (void)endShow {
    VOLogI(VOTTProto, @"endShow");
    if (self.player) {
        [self.player stopPlayerStream];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
}

- (void)pageViewControllerVisible:(BOOL)visible {
    VOLogI(VOTTProto, @"visible: %d", visible);
    if (visible) {
        self.player = [[TTLivePlayerManager sharedLiveManager] createLivePlayer];
        [self.player bindStreamView:self.renderView];
        [self.player playerStreamWith:self.mixModel.liveModel];
    }
}

- (void)pageViewControllerVisibleForOtherItem:(BOOL)visible {
    VOLogI(VOTTProto, @"visible: %d", visible);
    if (visible) {
        self.player = [[TTLivePlayerManager sharedLiveManager] createLivePlayer];
    } else {
        self.player = nil;
    }
}

#pragma mark -- TTLiveCell
- (TTLiveModel *)getLiveModel {
    return self.mixModel.liveModel;
}

- (UIView *)getRenderView {
    return self.renderView;
}

#pragma mark -- getter&setter
- (void)setMixModel:(TTMixModel *)mixModel {
    _mixModel = mixModel;
    TTLiveModel *liveModel = mixModel.liveModel;
    self.titleLabel.text = [NSString stringWithFormat:@"@%@", liveModel.hostName];
    self.subtitleLabel.text = liveModel.roomDescription;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:liveModel.coverUrl]];
}

- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (UIView *)statusView {
    if (!_statusView) {
        _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 78, 20)];
        _statusView.layer.cornerRadius = 2;
        _statusView.layer.masksToBounds = YES;
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = _statusView.bounds;
        gradientLayer.colors = @[
            (__bridge id)[UIColor colorFromHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromHexString:@"#ED3495"].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        [_statusView.layer insertSublayer:gradientLayer atIndex:0];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tt_live_status" bundleName:@"TTProto"]];
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalizedStringFromBundle(@"tt_live_status", @"TTProto");
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        label.textColor = [UIColor whiteColor];
        [_statusView addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.left.equalTo(_statusView).offset(5);
            make.centerY.equalTo(_statusView);
        }];
        [_statusView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(icon.mas_right).offset(2);
            make.centerY.equalTo(icon);
        }];
    }
    return _statusView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.tag = 3001;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.tag = VEInterfaceSubtitleTag;
        _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.numberOfLines = 2;
    }
    return _subtitleLabel;
}

- (UIButton *)enterRoomBtn {
    if (!_enterRoomBtn) {
        _enterRoomBtn = [[UIButton alloc] init];
        _enterRoomBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        _enterRoomBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 24, 8, 24);
        _enterRoomBtn.contentEdgeInsets = UIEdgeInsetsZero;
        _enterRoomBtn.layer.borderWidth = 1;
        _enterRoomBtn.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
        _enterRoomBtn.layer.cornerRadius = 18;
        _enterRoomBtn.layer.masksToBounds = YES;
        [_enterRoomBtn setTitle:LocalizedStringFromBundle(@"tt_live_btn_text", @"TTProto") forState:UIControlStateNormal];
        [_enterRoomBtn setImage:[UIImage imageNamed:@"tt_live_ing" bundleName:@"TTProto"] forState:UIControlStateNormal];
        [_enterRoomBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, -3)];
        [_enterRoomBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 3)];
        [_enterRoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _enterRoomBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_enterRoomBtn addTarget:self action:@selector(enterLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterRoomBtn;
}
@end
