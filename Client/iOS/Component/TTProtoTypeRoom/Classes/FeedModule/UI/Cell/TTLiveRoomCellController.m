//
//  TTLiveRoomCellController.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import "TTLiveRoomCellController.h"
#import "LiveHostAvatarView.h"
#import "LivePeopleNumView.h"
#import "LiveRoomBottomView.h"
#import "LiveSendGiftComponent.h"
#import "LiveGiftEffectComponent.h"
#import "LiveSendLikeComponent.h"
#import "BaseUserModel.h"
#import "TTRTSManager.h"
#import "TTRTCManager.h"
#import "LiveTextInputComponent.h"
#import "TTLivePlayerController.h"
#import "NetworkingManager+TTProto.h"
#import "TTLivePlayerManager.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface TTLiveRoomCellController () <LiveRoomBottomViewDelegate, LiveGiftItemComponentDelegate>
@property (nonatomic, strong) LiveHostAvatarView *hostAvatarView;
@property (nonatomic, strong) LivePeopleNumView *peopleNumView;
@property (nonatomic, strong) BaseButton *closeLiveButton;
@property (nonatomic, strong) LiveRoomBottomView *bottomView;
@property (nonatomic, strong) BaseIMComponent *imComponent;
@property (nonatomic, strong) LiveSendGiftComponent *sendGifgComponent;
@property (nonatomic, strong) LiveGiftEffectComponent *giftEffectComponent;
@property (nonatomic, strong) LiveSendLikeComponent *sendLikeComponent;
@property (nonatomic, strong) LiveTextInputComponent *inputComponent;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *renderView;

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) TTLivePlayerController *player;

@property (nonatomic, assign) Boolean isSendLikeOk;

@end

@implementation TTLiveRoomCellController
@synthesize reuseIdentifier;

#pragma mark -- system method override
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    VOLogI(VOTTProto, @"removeFromParentViewController");
}

#pragma mark -- private method
- (void)initUI {
    VOLogI(VOTTProto, @"initUI");
    [self.view addSubview:self.renderView];
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.renderView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.renderView);
    }];
    
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.containerView addSubview:self.hostAvatarView];
    [self.hostAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36);
        make.left.equalTo(self.containerView).offset(12);
        make.top.equalTo(self.containerView).offset(44);
    }];
    
    [self.containerView addSubview:self.closeLiveButton];
    [self.closeLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.equalTo(self.containerView).offset(-8);
        make.centerY.equalTo(self.hostAvatarView);
    }];
    
    [self.containerView addSubview:self.peopleNumView];
    [self.peopleNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.right.equalTo(self.closeLiveButton.mas_left).offset(-8);
        make.centerY.equalTo(self.closeLiveButton);
    }];
    
    [self.containerView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView.mas_safeAreaLayoutGuideBottom).offset(-30);
        make.height.mas_equalTo(36);
    }];
    
    [self.containerView addSubview:self.imComponent.baseIMView];
    [self.imComponent.baseIMView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-8);
        make.height.mas_equalTo(184);
        make.right.mas_equalTo(-56);
    }];
}

// joinRTCRoom
- (void)joinTTLiveRoom {
    [[TTRTCManager shareRtc] joinRoomByToken:self.liveModel.rtsToken
                                      roomID:self.liveModel.roomId
                                      userID:[LocalUserComponent userModel].uid];
}

// register Listeners
- (void)addListeners {
    __weak __typeof(self) weak_self = self;
    [TTRTSManager registerOnLiveFeedJoinRoomWithBlock:^(NSInteger audienceCount) {
//        [weak_self updateAudiencencount:audienceCount];
//        weak_self.containerView.hidden = NO;
    }];
    
    [TTRTSManager registerOnLiveFeedUserJoinRoom:^(NSString * _Nonnull userId, NSString * _Nonnull userName, NSInteger audienceCount) {
        [weak_self updateAudiencencount:audienceCount];
        if (weak_self.containerView.hidden) {
            weak_self.containerView.hidden = NO;
        }
    }];
    
    [TTRTSManager registerOnLiveFeedUserLeaveRoom:^(NSString * _Nonnull userId, NSString * _Nonnull userName, NSInteger audienceCount) {
        [weak_self updateAudiencencount:audienceCount];
    }];
    
    [TTRTSManager registerOnLiveFeedMessageSendWithBlock:^(NSString * _Nonnull userId, NSString * _Nonnull userName, LiveMessageModel * _Nonnull messageModel) {
        [weak_self onReciveMessageFromRoom:messageModel];
    }];
}

- (void)updateAudiencencount:(NSInteger)count {
    [self.peopleNumView updateTitleLabel:count];
}

- (void)onReciveMessageFromRoom:(LiveMessageModel *)messageModel {
    switch (messageModel.type) {
        case LiveMessageModelStateNormal: {
            BaseIMModel *imModel = [[BaseIMModel alloc] init];
            if ([messageModel.userId isEqualToString:self.liveModel.hostUserId]) {
                NSString *imageName = @"im_host";
                imModel.iconImage = [UIImage imageNamed:imageName bundleName:@"LiveRoomUI"];
            }
            imModel.userID = messageModel.userId;
            imModel.userName = messageModel.userName;
            imModel.message = messageModel.content;
            [self.imComponent addIM:imModel];
            break;
        }
        case LiveMessageModelStateGift: {
            // gift track animation
            LiveGiftEffectModel *model = [[LiveGiftEffectModel alloc] initWithMessage:messageModel];
            [self.giftEffectComponent addTrackToQueue:model];
            break;
        }
        case LiveMessageModelStateLike: {
            // like animation
            if ([messageModel.userId isEqualToString:[LocalUserComponent userModel].uid]) {
                break;
            }
            [self.sendLikeComponent show];
            break;
        }
        default:
            break;
    }
}

- (void)closeLiveButtonAction {
    [[TTRTCManager shareRtc] leaveRoom];
    [[TTLivePlayerManager sharedLiveManager] recoveryAllPlayerWithException:self.player];
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)loadDataWithSendLikeMessage {
    [self.sendLikeComponent show];
    if (self.isSendLikeOk) {
        LiveMessageModel *messageModel = [[LiveMessageModel alloc] init];
        messageModel.type = LiveMessageModelStateLike;
        messageModel.content = @"send like";
        messageModel.userId = [LocalUserComponent userModel].uid;
        messageModel.userName = [LocalUserComponent userModel].name;
        [NetworkingManager sendMessageInLiveRoom:self.liveModel.roomId
                                          userId:[LocalUserComponent userModel].uid
                                    messageModel:messageModel success:^{
            VOLogI(VOTTProto,@"send like");
        } failure:^(NSString * _Nonnull errorMessage) {
            [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
        }];
        self.isSendLikeOk = NO;
        [self performSelector:@selector(unlockSendLike) withObject:nil afterDelay:0.1];
    }
}

- (void)unlockSendLike {
    self.isSendLikeOk = YES;
}
- (void) loadDataWithSendGiftType:(GiftType)giftType {
    LiveMessageModel *messageModel = [[LiveMessageModel alloc] init];
    messageModel.type = LiveMessageModelStateGift;
    messageModel.content = @"send gift";
    messageModel.count = 1;
    messageModel.giftType = giftType;
    messageModel.userId = [LocalUserComponent userModel].uid;
    messageModel.userName = [LocalUserComponent userModel].name;
    [NetworkingManager sendMessageInLiveRoom:self.liveModel.roomId userId: [LocalUserComponent userModel].uid messageModel:messageModel success:^{
        VOLogI(VOTTProto,@"send gift: %ld",giftType);
    } failure:^(NSString * _Nonnull errorMessage) {
        [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
    }];
}
- (void)loadDataWithSendeMessage:(NSString *)content {
    LiveMessageModel *messageModel = [[LiveMessageModel alloc] init];
    messageModel.content = content;
    messageModel.userId = [LocalUserComponent userModel].uid;
    messageModel.userName = [LocalUserComponent userModel].name;
    messageModel.type = LiveMessageModelStateNormal;
    [NetworkingManager sendMessageInLiveRoom:self.liveModel.roomId
                                      userId:[LocalUserComponent userModel].uid
                                     messageModel:messageModel success:^{} failure:^(NSString * _Nonnull errorMessage) {
        [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
    }];
}

#pragma mark - VEPageItem protocol

- (void)itemDidLoad {
    VOLogI(VOTTProto, @"itemDidLoad");
    self.player = [[TTLivePlayerManager sharedLiveManager] createLivePlayer];
    if (self.player) {
        [self.player bindStreamView:self.renderView];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
}


- (void)itemDidRemoved {
    VOLogI(VOTTProto, @"itemDidRemoved");
    [[TTLivePlayerManager sharedLiveManager] recoveryPlayer:self.player];
    self.player = nil;
}

- (void)partiallyShow {
    VOLogI(VOTTProto, @"partiallyShow");
    if (self.player) {
        [self.player playerStreamWith:self.liveModel];
        [self.player setMute:YES];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
}

- (void)completelyShow {
    VOLogI(VOTTProto, @"completelyShow");
    if (self.player) {
        VOLogI(VOTTProto, @"completelyShow, playerAddress: %@", self.player);
        [self.player playerStreamWith:self.liveModel];
        [self.player setMute:NO];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
    [self addListeners];
    [self joinTTLiveRoom];
    self.isSendLikeOk = YES;
}

- (void)endShow {
    VOLogI(VOTTProto, @"endShow");
    if (self.player) {
        [self.player stopPlayerStream];
    } else {
        VOLogE(VOTTProto, @"player is nil");
    }
    self.containerView.hidden = YES;
}


#pragma mark - TTLiveCellProtocol

- (TTLiveModel *)getLiveModel {
    return self.liveModel;
}

- (UIView *)getRenderView {
    return self.renderView;
}

#pragma mark - LiveRoomBottomViewDelegate
- (void)liveRoomBottomView:(LiveRoomBottomView *)liveRoomBottomView itemButton:(LiveRoomItemButton *)itemButton roleStatus:(BottomRoleStatus)roleStatus {
    if (itemButton.currentState == LiveRoomItemButtonStateChat) {
        [self.inputComponent showWithRoomID:self.liveModel.roomId];
    } else if (itemButton.currentState == LiveRoomItemButtonStateGift) {
        [self.sendGifgComponent showWithRoomID:self.liveModel.roomId];
    } else if (itemButton.currentState == LiveRoomItemButtonStateLike) {
        // 点赞
        [self loadDataWithSendLikeMessage];
    }
}

#pragma mark -- LiveGiftItemComponentDelegate
- (void)liveGiftItemClickHandler:(GiftType)giftType {
    [self loadDataWithSendGiftType:giftType];
}

#pragma mark -- getter & setter

- (void)setLiveModel:(TTLiveModel *)liveModel {
    _liveModel = liveModel;
    self.hostAvatarView.userName = liveModel.hostName;
    self.hostAvatarView.avatarName = [BaseUserModel getAvatarNameWithUid:liveModel.hostUserId];
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

- (UIView *)containerView {
    if  (!_containerView) {
        _containerView = [[UIView alloc] init];
        self.containerView.hidden = YES;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (LiveHostAvatarView *)hostAvatarView {
    if (!_hostAvatarView) {
        _hostAvatarView = [[LiveHostAvatarView alloc] init];
        _hostAvatarView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _hostAvatarView.layer.cornerRadius = 18;
        _hostAvatarView.layer.masksToBounds = YES;
    }
    return _hostAvatarView;
}

- (LivePeopleNumView *)peopleNumView {
    if (!_peopleNumView) {
        _peopleNumView = [[LivePeopleNumView alloc] init];
        _peopleNumView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        _peopleNumView.layer.cornerRadius = 12;
        _peopleNumView.layer.masksToBounds = YES;
    }
    return _peopleNumView;
}

- (BaseButton *)closeLiveButton {
    if (!_closeLiveButton) {
        _closeLiveButton = [[BaseButton alloc] init];
        [self.closeLiveButton setImage:[UIImage imageNamed:@"create_live_close" bundleName:@"LiveRoomUI"] forState:UIControlStateNormal];
        _closeLiveButton.backgroundColor = [UIColor clearColor];
        [_closeLiveButton addTarget:self action:@selector(closeLiveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeLiveButton;
}

- (LiveRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[LiveRoomBottomView alloc] init];
        [_bottomView updateButtonRoleStatus:BottomRoleStatusTTAudience];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (BaseIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[BaseIMComponent alloc] initWithSuperView:self.containerView];
    }
    return _imComponent;
}

- (LiveSendGiftComponent *)sendGifgComponent {
    if (!_sendGifgComponent) {
        _sendGifgComponent = [[LiveSendGiftComponent alloc] initWithView:self.containerView];
        _sendGifgComponent.delegate = self;
    }
    return _sendGifgComponent;
}

- (LiveGiftEffectComponent *)giftEffectComponent {
    if (!_giftEffectComponent) {
        _giftEffectComponent = [[LiveGiftEffectComponent alloc] initWithView:self.containerView];
    }
    return _giftEffectComponent;
}

- (LiveSendLikeComponent *)sendLikeComponent {
    if (!_sendLikeComponent) {
        _sendLikeComponent = [[LiveSendLikeComponent alloc] initWithView:self.containerView];
    }
    return _sendLikeComponent;
}

- (LiveTextInputComponent *)inputComponent {
    if (!_inputComponent) {
        _inputComponent = [[LiveTextInputComponent alloc] init];
        __weak __typeof(self) wself = self;
        _inputComponent.clickSenderBlock = ^(NSString * _Nonnull text) {
            [wself loadDataWithSendeMessage:text];
        };
    }
    return _inputComponent;
}
@end
