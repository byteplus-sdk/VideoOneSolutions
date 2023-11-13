// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomViewController.h"
#import "LiveAddGuestsComponent.h"
#import "LiveCoHostComponent.h"
#import "LiveCountdownView.h"
#import "LiveEndLiveModel.h"
#import "LiveEndView.h"
#import "LiveEndViewController.h"
#import "LiveGiftEffectComponent.h"
#import "LiveHostAvatarView.h"
#import "LiveInformationComponent.h"
#import "LiveMediaComponent.h"
#import "LivePeopleNumView.h"
#import "LivePullStreamComponent.h"
#import "LivePushStreamComponent.h"
#import "LiveRTCManager.h"
#import "LiveRoomBottomView.h"
#import "LiveRoomSettingComponent.h"
#import "LiveRoomViewController+Report.h"
#import "LiveRoomViewController+SocketControl.h"
#import "LiveRtcLinkSession.h"
#import "LiveSendGiftComponent.h"
#import "LiveSendLikeComponent.h"
#import "LiveTextInputComponent.h"
#import <ToolKit/ReportComponent.h>

@interface LiveRoomViewController () <LiveRTCManagerReconnectDelegate, LiveRoomBottomViewDelegate, LiveMediaComponentDelegate, LiveAddGuestsComponentDelegate, LivePullStreamComponentDelegate, LiveCoHostComponentDelegate, LiveInteractiveDelegate, LiveRtcLinkSessionNetworkChangeDelegate>
@property (nonatomic, strong) LiveHostAvatarView *hostAvatarView;
@property (nonatomic, strong) LivePeopleNumView *peopleNumView;
@property (nonatomic, strong) BaseButton *closeLiveButton;
@property (nonatomic, strong) LiveRoomBottomView *bottomView;
@property (nonatomic, strong) BaseIMComponent *imComponent;
@property (nonatomic, strong) LiveInformationComponent *informationComponent;
@property (nonatomic, strong) LiveSendGiftComponent *sendGifgComponent;
@property (nonatomic, strong) LiveGiftEffectComponent *giftEffectComponent;
@property (nonatomic, strong) LiveSendLikeComponent *sendLikeComponent;
@property (nonatomic, strong) LiveCoHostComponent *coHostComponent;
@property (nonatomic, strong) LiveAddGuestsComponent *addGuestsComponent;
@property (nonatomic, strong) LivePullStreamComponent *livePullStreamComponent;
@property (nonatomic, strong) LivePushStreamComponent *livePushStreamComponent;
@property (nonatomic, strong) BytedEffectProtocol *beautyComponent;
@property (nonatomic, strong) LiveTextInputComponent *inputComponent;
@property (nonatomic, strong) LiveMediaComponent *mediaComponent;
@property (nonatomic, strong) LiveRoomSettingComponent *settingComponent;

@property (nonatomic, strong) UIView *liveView;

@property (nonatomic, strong) LiveRoomInfoModel *liveRoomModel;
@property (nonatomic, strong) LiveUserModel *currentUserModel;
@property (nonatomic, strong) NSString *streamPushUrl;
@property (nonatomic, weak) LiveEndViewController *endVC;
@property (nonatomic, assign) BOOL isSendLikeOk;

@property (nonatomic, strong) LiveRtcLinkSession *linkSession;

@end

@implementation LiveRoomViewController

- (instancetype)initWithRoomModel:(LiveRoomInfoModel *)liveRoomModel
                    streamPushUrl:(NSString *)streamPushUrl {
    self = [super init];
    if (self) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        _liveRoomModel = liveRoomModel;
        _streamPushUrl = streamPushUrl;
        _isSendLikeOk = YES;
        [LiveRTCManager shareRtc].businessDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBgGradientLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readApplyMessageNotification) name:NotificationReadApplyMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLiveTimeEndNotice) name:NotificationLiveTimeEnd object:nil];
    [self addSocketListener];
    if ([self isHost]) {
        self.linkSession = [[LiveRtcLinkSession alloc] initWithRoom:self.liveRoomModel];
        self.linkSession.interactiveDelegate = self;
        self.linkSession.netwrokDelegate = self;
    }

    [self joinRoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - Notification
- (void)readApplyMessageNotification {
    [self.bottomView updateButtonStatus:LiveRoomItemButtonStateAddGuests
                               isUnread:NO];
    [self.addGuestsComponent updateListUnread:NO];
}
- (void)receiveLiveTimeEndNotice {
    NSLog(@"receiveLiveTimeEndNotice");
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"minutes_error_message") delay:0.8];
    [self hangUp];
}

#pragma mark - LiveCoHostComponentDelegate
- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent
        invitePermitted:(NSArray *)userList
              rtcRoomID:(NSString *)rtcRoomID
               rtcToken:(NSString *)rtcToken {
    [self receivedCoHostJoin:userList
           otherAnchorRoomId:rtcRoomID
            otherAnchorToken:rtcToken];
}

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent inviteRejected:(NSArray *)userList rtcRoomID:(NSString *)rtcRoomID rtcToken:(NSString *)rtcToken {
    [self.linkSession stopInteractive];
    [self.linkSession startNormalStreaming];
}

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent haveSentPKRequestTo:(LiveUserModel *)userModel {
    [self.linkSession startInteractive:LiveInteractivePlayModePK];
}

- (void)coHostComponent:(LiveCoHostComponent *)coHostComponent dealExceptionalCase:(RTSACKModel *)model {
    [self receivedCoHostEnd];
}

#pragma mark - LiveAddGuestsComponentDelegate

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent
        clickMoreButton:(LiveUserModel *)model {
    [self.mediaComponent show:LiveMediaStatusGuests
                    userModel:self.currentUserModel];
}

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent
       updateUserStatus:(LiveInteractStatus)status {
    self.currentUserModel.status = status;
}

- (void)guestsComponent:(LiveAddGuestsComponent *)guestsComponent clickAgree:(LiveUserModel *)model {
    // anchor side, permit guest online.
    [self.linkSession startInteractive:LiveInteractivePlayModeMultiGuests];
}

#pragma mark - LiveRoomBottomViewDelegate

- (void)liveRoomBottomView:(LiveRoomBottomView *_Nonnull)liveRoomBottomView
                itemButton:(LiveRoomItemButton *_Nullable)itemButton
                roleStatus:(BottomRoleStatus)roleStatus {
    if (itemButton.currentState == LiveRoomItemButtonStatePK) {
        if (self.addGuestsComponent.isConnect) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"audience_connection_error")];
        } else {
            [self clickBottomCoHost:liveRoomBottomView
                         itemButton:itemButton
                         roleStatus:roleStatus];
        }
    } else if (itemButton.currentState == LiveRoomItemButtonStateAddGuests) {
        [self clickBottomAddGuests:liveRoomBottomView
                        itemButton:itemButton
                        roleStatus:roleStatus];
    } else if (itemButton.currentState == LiveRoomItemButtonStateBeauty) {
        if (self.beautyComponent) {
            [self.beautyComponent showWithView:self.view dismissBlock:^(BOOL result){

            }];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"not_support_beauty_error")];
        }
    } else if (itemButton.currentState == LiveRoomItemButtonStateMore) {
        [self.mediaComponent show:LiveMediaStatusHost
                        userModel:self.currentUserModel];
    } else if (itemButton.currentState == LiveRoomItemButtonStateGift) {
        [self.sendGifgComponent show];
    } else if (itemButton.currentState == LiveRoomItemButtonStateLike) {
        [self loadDataWithSendLikeMessage];
    } else if (itemButton.currentState == LiveRoomItemButtonStateChat) {
        [self.inputComponent show];
    } else if (itemButton.currentState == LiveRoomItemButtonStateData) {
        [self.informationComponent show];
    } else if (itemButton.currentState == LiveRoomItemButtonStateReport) {
        [self showBlockAndReportLiveRoom:self.liveRoomModel.roomID];
    }
}

#pragma mark - LiveMediaComponentDelegate
- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
           clickCancel:(BOOL)isClick {
}

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
       clickDisconnect:(BOOL)isClick {
    [self loadDataWithAudienceLinkmicLeave];
    [self.mediaComponent close];
}

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent clickStreamInfo:(BOOL)isClick {
    self.informationComponent.linkSession = self.linkSession;
    [self.informationComponent show];
}

#pragma mark - LivePullStreamComponentDelegate
- (void)pullStreamComponent:(LivePullStreamComponent *)pullStreamComponent
            didChangeStatus:(PullRenderStatus)status {
}

#pragma mark - Reconnect

- (void)reconnectLiveRoom {
    // Reconnection after network disconnection
    __weak __typeof(self) wself = self;
    [LiveRTSManager reconnect:self.liveRoomModel.roomID
                        block:^(LiveReconnectModel *reconnectModel, RTSACKModel *model) {
                            if (model.result) {
                                // Reconnect successfully, restore the status in the room
                                [wself joinRoom];
                            } else if (model.code == RTSStatusCodeUserIsInactive ||
                                       model.code == RTSStatusCodeRoomDisbanded ||
                                       model.code == RTSStatusCodeUserNotFound) {
                                // The user has left the room/live has ended, exit the room.
                                [[ToastComponent shareToastComponent] showWithMessage:model.message delay:0.8];
                                [wself hangUp];
                            } else {
                            }
                        }];
}

#pragma mark - Network request

- (void)loadDataWithJoinLiveRoom {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveJoinLiveRoom:self.liveRoomModel.roomID
                               block:^(LiveRoomInfoModel *roomModel,
                                       LiveUserModel *userModel,
                                       RTSACKModel *model) {
                                   [[ToastComponent shareToastComponent] dismiss];
                                   if (model.result) {
                                       [wself restoreRoomWithRoomInfoModel:roomModel
                                                                 userModel:userModel
                                                               rtcUserList:@[]];
                                   } else {
                                       [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"joining_room_failed") block:^(BOOL result) {
                                           [wself hangUp];
                                       }];
                                   }
                               }];
}

- (void)loadDataWithAudienceLinkmicLeave {
    __weak __typeof(self) wself = self;
    NSString *linkerID = [self.addGuestsComponent getLinkerIdWithUid:[LocalUserComponent userModel].uid];
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAudienceLinkmicLeave:self.liveRoomModel.roomID
                                    linkerID:linkerID
                                       block:^(RTSACKModel *_Nonnull model) {
                                           [[ToastComponent shareToastComponent] dismiss];
                                           if (model.result) {
                                               // Make audience update bottom ui
                                               [wself.bottomView updateButtonRoleStatus:BottomRoleStatusAudience];
                                               [wself.imComponent updateRightConstraintValue:-56];
                                           } else {
                                               [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                           }
                                       }];
}

- (void)loadDataWithupdateRes:(LiveUserModel *)loginUserModel {
    BOOL isHost = (loginUserModel.role == 2);
    CGSize videoSize = isHost ? [LiveSettingVideoConfig defultVideoConfig].videoSize : [LiveSettingVideoConfig defultVideoConfig].guestVideoSize;
    [LiveRTSManager liveUpdateResWithSize:videoSize
                                   roomID:self.liveRoomModel.roomID
                                    block:^(RTSACKModel *_Nonnull model) {
                                        if (model.result) {
                                            if (isHost) {
                                                // Streamers update merge resolution and RTC encoding resolution
                                                [[LiveRTCManager shareRtc] updateLiveTranscodingResolution:videoSize];
                                                [[LiveRTCManager shareRtc] updateVideoEncoderResolution:videoSize];
                                            } else {
                                                // Guests update RTC encoding resolution
                                                [[LiveRTCManager shareRtc] updateVideoEncoderResolution:videoSize];
                                            }
                                        }
                                    }];
}

- (void)loadDataWithSendLikeMessage {
    [self.sendLikeComponent show];
    if (self.isSendLikeOk) {
        LiveMessageModel *messageModel = [[LiveMessageModel alloc] init];
        messageModel.type = LiveMessageModelStateLike;
        messageModel.content = @"send like";
        messageModel.user_id = [LocalUserComponent userModel].uid;
        messageModel.user_name = [LocalUserComponent userModel].name;
        [LiveRTSManager sendIMMessage:messageModel
                                block:^(RTSACKModel *_Nonnull model) {
                                    NSLog(@"send like");
                                }];
        self.isSendLikeOk = NO;
        [self performSelector:@selector(unlockSendLike) withObject:nil afterDelay:0.1];
    }
}

- (void)unlockSendLike {
    self.isSendLikeOk = YES;
}

#pragma mark - SocketControl
- (void)addUser:(LiveUserModel *)userModel audienceCount:(NSInteger)audienceCount {
    [self.peopleNumView updateTitleLabel:audienceCount];
}

- (void)removeUser:(LiveUserModel *)userModel audienceCount:(NSInteger)audienceCount {
    if ([self isHost]) {
        [self.addGuestsComponent updateList];
    }
    [self.peopleNumView updateTitleLabel:audienceCount];
}

- (void)receivedIMMessage:(LiveMessageModel *)message
            sendUserModel:(LiveUserModel *)sendUserModel {
    switch (message.type) {
        case LiveMessageModelStateNormal: {
            if ([ReportComponent containsBlockedKey:sendUserModel.user_id]) {
                // Filter and block user messages
                return;
            }
            BaseIMModel *imModel = [[BaseIMModel alloc] init];
            if ([sendUserModel.user_id isEqualToString:self.liveRoomModel.hostUserModel.uid]) {
                NSString *imageName = @"im_host";
                imModel.iconImage = [UIImage imageNamed:imageName bundleName:HomeBundleName];
            }
            imModel.userID = sendUserModel.user_id;
            imModel.userName = sendUserModel.user_name ? sendUserModel.user_name : message.user_name;
            imModel.message = message.content;
            [self.imComponent addIM:imModel];
            __weak __typeof(self) wself = self;
            imModel.clickBlock = ^(BaseIMModel *_Nonnull model) {
                if (![model.userID isEqualToString:[LocalUserComponent userModel].uid]) {
                    [wself showBlockAndReportUser:model.userID];
                }
            };
            break;
        }

        case LiveMessageModelStateGift: {
            // gift track animation
            LiveGiftEffectModel *model = [[LiveGiftEffectModel alloc] initWithMessage:message sendUserModel:sendUserModel];
            [self.giftEffectComponent addTrackToQueue:model];
            break;
        }
        case LiveMessageModelStateLike: {
            // like animation
            if ([sendUserModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
                break;
            }
            [self.sendLikeComponent show];
            break;
        }
        default:
            break;
    }
}
- (void)receivedCoHostInviteWithUser:(LiveUserModel *)inviter
                            linkerID:(NSString *)linkerID
                               extra:(NSString *)extra {
    [self.coHostComponent bindLinkerId:linkerID uid:inviter.uid];
    [self.coHostComponent pushToInviteList:inviter];
    [self.inputComponent disappear];
    [self.coHostComponent dismissInviteList];
    [self.addGuestsComponent dismissList];
    [self.linkSession startInteractive:LiveInteractivePlayModePK];
}

- (void)receivedCoHostRefuseWithUser:(LiveUserModel *)invitee {
    //    [self.coHostComponent refreshSendPkState];
    NSString *message = LocalizedString(@"not_available_live");
    [[ToastComponent shareToastComponent] showWithMessage:message];
    [self.bottomView updateButtonStatus:LiveRoomItemButtonStatePK touchStatus:LiveRoomItemTouchStatusNone];
    [self.linkSession stopInteractive];
    [self.linkSession startNormalStreaming];
}

- (void)receivedCoHostSucceedWithUser:(LiveUserModel *)invitee
                             linkerID:(NSString *)linkerID {
    //    [self.coHostComponent refreshSendPkState];
    self.coHostComponent.linkerID = linkerID;
    NSString *message = LocalizedString(@"succeed_available_live");
    [[ToastComponent shareToastComponent] showWithMessage:message];
}

- (void)receivedCoHostJoin:(NSArray<LiveUserModel *> *)userlList
         otherAnchorRoomId:(NSString *)otherRoomId
          otherAnchorToken:(NSString *)otherToken {
    // Enable span the room retweet stream
    [self.linkSession startForwardStreamToRooms:otherRoomId token:otherToken];
    [self.linkSession onUserListChanged:userlList];
    // Show make cohost interface
    [self.coHostComponent startCoHostBattleWithUsers:userlList];
    [self.bottomView updateButtonStatus:LiveRoomItemButtonStatePK
                            touchStatus:LiveRoomItemTouchStatusClose];
}

- (void)receivedCoHostEnd {
    if ([self isHost]) {
        NSString *message = LocalizedString(@"pk_disconnected");
        [[ToastComponent shareToastComponent] showWithMessage:message];
        [self.coHostComponent closeCoHost];
        [self.coHostComponent closeDuringPK];
        [self.linkSession stopInteractive];
        [self.linkSession startNormalStreaming];
        [self.livePushStreamComponent openWithUserModel:self.currentUserModel];
        [self.bottomView updateButtonStatus:LiveRoomItemButtonStatePK touchStatus:LiveRoomItemTouchStatusNone];
    }
}
- (void)receivedAddGuestsApplyWithUser:(LiveUserModel *)applicant
                              linkerID:(NSString *)linkerID
                                 extra:(NSString *)extra {
    [self.addGuestsComponent bindLinkerId:linkerID uid:applicant.uid];
    if ([self isHost]) {
        if ([self.addGuestsComponent IsDisplayApplyList]) {
            [self.addGuestsComponent updateList];
        } else {
            [self.bottomView updateButtonStatus:LiveRoomItemButtonStateAddGuests
                                       isUnread:YES];
            [self.addGuestsComponent updateListUnread:YES];
        }
        [self.coHostComponent dismissInviteList];
    }
}

- (void)receivedAddGuestsInviteWithUser:(LiveUserModel *)inviter
                               linkerID:(NSString *)linkerID
                                  extra:(NSString *)extra {
}

- (void)receivedAddGuestsManageGuestMedia:(NSString *)uid
                                   camera:(NSInteger)camera
                                      mic:(NSInteger)mic {
    if (![uid isEqualToString:[LocalUserComponent userModel].uid]) {
        return;
    }
    BOOL cameraBool = self.currentUserModel.camera;
    BOOL micBool = self.currentUserModel.mic;
    if (camera != -1) {
        cameraBool = camera == 1 ? YES : NO;
    }
    if (mic != -1) {
        micBool = mic == 1 ? YES : NO;
    }
    [self.mediaComponent close];
    [self.addGuestsComponent updateGuestsCamera:cameraBool uid:uid];
    [self.addGuestsComponent updateGuestsMic:micBool uid:uid];
    if (camera != -1 && !cameraBool) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"off_camera_title")];
    }
    if (mic != -1 && !micBool) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"off_mic_title")];
    }
    self.currentUserModel.camera = cameraBool;
    self.currentUserModel.mic = micBool;
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveUpdateMediaMic:micBool
                                camera:cameraBool
                                 block:^(RTSACKModel *_Nonnull model) {
                                     [wself.linkSession switchVideoCapture:cameraBool];
                                     [wself.linkSession switchAudioCapture:micBool];
                                 }];
}
- (void)receivedAddGuestsSucceedWithUser:(LiveUserModel *)invitee
                                linkerID:(NSString *)linkerID
                               rtcRoomID:(NSString *)rtcRoomID
                                rtcToken:(NSString *)rtcToken {
    [self.addGuestsComponent bindLinkerId:linkerID uid:invitee.uid];
    if (![self isHost]) {
        // Become a guest to update the bottom UI
        [self.bottomView updateButtonRoleStatus:BottomRoleStatusGuests];
        // Become a guest and join the RTC room(Host invites audience)
        self.liveRoomModel.rtcToken = rtcToken;
        self.liveRoomModel.rtcRoomId = rtcRoomID;
        // guest online, should realloc linksession to clear every state.
        self.linkSession = [[LiveRtcLinkSession alloc] initWithRoom:self.liveRoomModel];
        self.linkSession.netwrokDelegate = self;
        self.linkSession.interactiveDelegate = self;
        [self.linkSession startInteractive:LiveInteractivePlayModeMultiGuests];
        // Guests restore beauty special effects
        [self.beautyComponent resume];

        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"co-host_join_succeed_title") describe:LocalizedString(@"co-host_join_succeed_describe") status:ToastViewStatusSucceed];
    }
}

- (void)receivedAddGuestsRefuseWithUser:(LiveUserModel *)invitee {
    NSString *message = @"";
    if ([self isHost]) {
        message = [NSString stringWithFormat:LocalizedString(@"%@refuses_connect"), invitee.name];
        [[ToastComponent shareToastComponent] showWithMessage:message];
        [self.addGuestsComponent updateList];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"co-host_request_denied_title") describe:LocalizedString(@"co-host_request_denied_describe") status:ToastViewStatusWarning];
        self.currentUserModel.status = LiveInteractStatusOther;
        [self.addGuestsComponent closeApply];
        [self.addGuestsComponent closePending];
    }
}
- (void)receivedAddGuestsJoin:(NSArray<LiveUserModel *> *)userList {
    if ([self isHost]) {
        if (userList.count < 2) {
            return;
        }
        [self.livePushStreamComponent close];
        [self.linkSession onUserListChanged:userList];
        [self.addGuestsComponent showAddGuests:self.liveView
                                       hostUid:self.liveRoomModel.anchorUserID
                                      userList:userList];
        //        [self.addGuestsComponent updateList];
        [self.bottomView updateButtonStatus:LiveRoomItemButtonStateAddGuests touchStatus:LiveRoomItemTouchStatusIng];
        if (userList.count == 2) {
            [self.addGuestsComponent updateFirstGuestLinkMicTime:[NSDate date]];
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"agree_link_mic")];
        }
    } else {
        self.currentUserModel.status = LiveInteractStatusAudienceLink;
        [self.livePullStreamComponent close];
        [self.addGuestsComponent showAddGuests:self.liveView
                                       hostUid:self.liveRoomModel.anchorUserID
                                      userList:userList];
        [self.addGuestsComponent closePending];
        [self.bottomView updateButtonRoleStatus:BottomRoleStatusGuests];
        [self.bottomView updateButtonStatus:LiveRoomItemButtonStateAddGuests touchStatus:LiveRoomItemTouchStatusIng];
    }
    [self.imComponent updateRightConstraintValue:-144];
}
- (void)receivedAddGuestsRemoveWithUser:(NSString *)uid
                               userList:(NSArray<LiveUserModel *> *)userList {
    if ([self isHost]) {
        NSString *userName = [self.addGuestsComponent removeAddGuestsUid:uid userList:userList];
        [self.linkSession onUserListChanged:userList];
        if (userName != nil) {
            NSString *message = LocalizedString(@"disconnected_live");
            [self.addGuestsComponent updateList];
            [[ToastComponent shareToastComponent] showWithMessage:message];
        }
    } else {
        if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"host_disconnected_live")];
            [self.addGuestsComponent closeAddGuests];
            [self.addGuestsComponent closeApply];
            // guest is offline. linksession is not needed recently.
            [self.linkSession stopInteractive];
            self.linkSession = nil;
            [self.mediaComponent close];
            [self.livePullStreamComponent open:self.liveRoomModel];
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusAudience];
            self.currentUserModel.status = LiveInteractStatusOther;
        } else {
            NSString *userName = [self.addGuestsComponent removeAddGuestsUid:uid userList:userList];
            if (userName != nil) {
                NSString *message = LocalizedString(@"disconnected_live");
                [[ToastComponent shareToastComponent] showWithMessage:message];
            }
        }
    }
}
- (void)receivedCancelApplyLinkmicWithUser:(NSString *)uid
                                    roomId:(NSString *)roomId {
    [self.addGuestsComponent updateApplicationList];
}

- (void)receivedAddGuestsEnd {
    if ([self isHost]) {
        [self.addGuestsComponent closeAddGuests];
        [self.linkSession startNormalStreaming];
        [self.linkSession stopInteractive];
        [self.addGuestsComponent updateList];
        [self.livePushStreamComponent openWithUserModel:self.currentUserModel];
        [self.bottomView updateButtonStatus:LiveRoomItemButtonStateAddGuests
                                touchStatus:LiveRoomItemTouchStatusNone];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"host_disconnected_live")];
        [self.addGuestsComponent closeAddGuests];
        [self.addGuestsComponent closeApply];
        [self.linkSession stopInteractive];
        self.linkSession = nil;
        [self.livePullStreamComponent open:self.liveRoomModel];
        [self.bottomView updateButtonRoleStatus:BottomRoleStatusAudience];
        self.currentUserModel.status = LiveInteractStatusOther;
    }
    [self.imComponent updateRightConstraintValue:-56];
}

- (void)receivedLiveEnd:(NSString *)type endLiveInfo:(LiveEndLiveModel *)info {
    if ([type integerValue] == 2) {
        // timeout close
        if ([self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"minutes_error_message") delay:0.8];
        } else {
            // Audience & Guests
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"live_ended") delay:0.8];
        }
    } else if ([type integerValue] == 3) {
        // Illegal close
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"closed_terms_service") delay:0.8];
    } else {
        if (![self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"live_ended") delay:0.8];
        }
    }
    if ([self isHost]) {
        self.linkSession = nil;
        info.userAvatarImageUrl = [LiveUserModel getAvatarNameWithUid:self.liveRoomModel.anchorUserID];
        info.userName = self.liveRoomModel.anchorUserName;
        if (!self.endVC) {
            LiveEndViewController *next = [[LiveEndViewController alloc] initWithModel:info];
            next.modalPresentationStyle = UIModalPresentationFullScreen;
            __weak __typeof(next) wnext = next;
            next.backBlock = ^{
                __strong __typeof(wnext) snext = wnext;
                [snext dismissViewControllerAnimated:YES completion:nil];
            };
            _endVC = next;
            [self navigationControllerPop];
            [[DeviceInforTool topViewController] presentViewController:next animated:NO completion:nil];
        }
    } else {
        [self navigationControllerPop];
    }
}
- (void)receivedRoomStatus:(LiveInteractStatus)status {
    LiveInteractStatus currentStatus = self.liveRoomModel.hostUserModel.status;
    self.liveRoomModel.hostUserModel.status = status;
    if (currentStatus == LiveInteractStatusHostLink &&
        status == LiveInteractStatusOther) {
        [self receivedCoHostEnd];
    }
}

- (void)receivedAddGuestsMediaChangeWithUser:(NSString *)uid
                                 operatorUid:(NSString *)operatorUid
                                      camera:(BOOL)camera
                                         mic:(BOOL)mic {
    [self changeMediaWithUser:uid camera:camera mic:mic];
}

- (void)receivedLeaveTemporary:(NSString *)uid
                      userName:(NSString *)userName
                      userRole:(NSString *)userRole {
    NSString *message = @"";
    if ([userRole integerValue] == 2) {
        message = LocalizedString(@"host_back_soon");
    } else {
        message = LocalizedString(@"guest_back_soon");
    }
    [[ToastComponent shareToastComponent] showWithMessage:message];
}

#pragma mark - LiveRtcLinkSessionNetworkChangeDelegate
- (void)updateOnNetworkStatusChange:(LiveCoreNetworkQuality)status {
    switch (status) {
        case LiveCoreNetworkQualityExcellent:
            [self.livePushStreamComponent updateNetworkQuality:LiveNetworkQualityStatusGood];
            break;
        case LiveCoreNetworkQualityPoor:
        case LiveCoreNetworkQualityBad:
            [self.livePushStreamComponent updateNetworkQuality:LiveNetworkQualityStatusBad];
            break;
        case LiveCoreNetworkQualityUnknown:
            [self.livePushStreamComponent updateNetworkQuality:LiveNetworkQualityStatusBad];
            break;
        default:
            [self.livePushStreamComponent updateNetworkQuality:LiveNetworkQualityStatusBad];
            break;
    }
}

#pragma mark - LiveRTCManagerReconnectDelegate
- (void)LiveRTCManagerReconnectDelegate:(LiveRTCManager *)manager onRoomStateChanged:(RTCJoinModel *)joinModel uid:(NSString *)uid {
    if (joinModel.joinType == 0) {
        // Entering the room for the first time
        if ([self isHost]) {
            // turn on the merge and retweet
            [[LiveRTCManager shareRtc]
                startMixStreamRetweetWithPushUrl:self.streamPushUrl
                                        hostUser:self.liveRoomModel.hostUserModel
                                       rtcRoomId:self.liveRoomModel.rtcRoomId];

            //            [[LiveRTCManager shareRtc] stopNormalStreaming];
        }
    } else {
        // Entering the room after reconnection
        [self reconnectLiveRoom];
    }
}

#pragma makr-- LiveInteractiveDelegate
- (void)liveInteractiveOnUserPublishStream:(NSString *)uid {
    if (self.linkSession) {
        // handle cohost events.
        if (self.coHostComponent.isConnect) {
            [self.coHostComponent updateCoHostRoomView:self.liveView
                                         userModelList:self.linkSession.userList
                                        loginUserModel:self.currentUserModel];
            [self.livePushStreamComponent close];
        }
    }
}

#pragma mark - Private Action

- (void)closeLiveButtonAction {
    if ([self isHost]) {
        __weak __typeof(self) wself = self;
        AlertActionModel *alertModel = [[AlertActionModel alloc] init];
        alertModel.title = LocalizedString(@"end_live_title");
        alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
            if ([action.title isEqualToString:LocalizedString(@"end_live_title")]) {
                [wself hangUp];
            }
        };
        AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
        alertCancelModel.title = LocalizedString(@"cancel");
        NSString *title = LocalizedString(@"end_live_alert");
        NSString *message = LocalizedString(@"end_live_alert_info");
        [[AlertActionManager shareAlertActionManager] showWithTitle:title message:message actions:@[alertCancelModel, alertModel] alertUserModel:nil];
    } else {
        [self hangUp];
    }
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.liveView];
    [self.liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.view addSubview:self.hostAvatarView];
    [self.hostAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36);
        make.left.equalTo(self.view).offset(12);
        make.top.equalTo(self.view).offset([DeviceInforTool getStatusBarHight] + 2);
    }];

    [self.view addSubview:self.closeLiveButton];
    [self.closeLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.equalTo(self.view).offset(-8);
        make.centerY.equalTo(self.hostAvatarView);
    }];

    [self.view addSubview:self.peopleNumView];
    [self.peopleNumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.right.equalTo(self.closeLiveButton.mas_left).offset(-8);
        make.centerY.equalTo(self.closeLiveButton);
    }];

    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(-[DeviceInforTool getVirtualHomeHeight]);
        make.height.mas_equalTo(36);
    }];

    [self imComponent];
}
- (void)updateLayoutToRole:(LiveUserModel *)userModel
               rtcUserList:(NSArray<LiveUserModel *> *)rtcUserList {
    if (userModel.role == LiveUserRoleHost) {
        // Host
        if (userModel.status == LiveInteractStatusHostLink) {
            // Make coHsot
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusHost];
            [self.bottomView updateButtonStatus:LiveRoomItemButtonStatePK touchStatus:LiveRoomItemTouchStatusClose];
        } else if (userModel.status == LiveInteractStatusAudienceLink) {
            // Make Guests
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusHost];
            [self.addGuestsComponent showAddGuests:self.liveView
                                           hostUid:self.liveRoomModel.anchorUserID
                                          userList:rtcUserList];
        } else {
            // make live
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusHost];
            [self.livePushStreamComponent openWithUserModel:userModel];
            [self.livePushStreamComponent updateHostMic:userModel.mic
                                                 camera:userModel.camera];
            if (self.addGuestsComponent.isConnect) {
                [self.addGuestsComponent closeAddGuests];
            }
            if (self.coHostComponent.isConnect) {
                [self.coHostComponent closeCoHost];
            }
        }
        [self.closeLiveButton setImage:[UIImage imageNamed:@"close_live" bundleName:HomeBundleName] forState:UIControlStateNormal];
    } else {
        // Audience
        if (userModel.status == LiveInteractStatusAudienceLink) {
            // Make Guests
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusGuests];
            [self.addGuestsComponent showAddGuests:self.liveView
                                           hostUid:self.liveRoomModel.anchorUserID
                                          userList:rtcUserList];
        } else {
            // Make audience, watch live
            [self.bottomView updateButtonRoleStatus:BottomRoleStatusAudience];
            [self.livePullStreamComponent open:self.liveRoomModel];
            if (self.addGuestsComponent.isConnect) {
                [self.addGuestsComponent closeAddGuests];
                self.linkSession = nil;
            }
        }
        [self.closeLiveButton setImage:[UIImage imageNamed:@"create_live_close" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    [self addBeautyEffect:userModel];
}
- (void)updatePullStatus:(LiveInteractStatus)status
               userCount:(NSInteger)userCount {
    if (![self isHost]) {
        PullRenderStatus pullStatus = PullRenderStatusNone;
        if (status == LiveInteractStatusHostLink) {
            pullStatus = PullRenderStatusPK;
        } else if (status == LiveInteractStatusAudienceLink) {
            pullStatus = userCount <= 2 ? PullRenderStatusTwoCoHost : PullRenderStatusMultiCoHost;
        }
        [self.livePullStreamComponent updateWithStatus:pullStatus];
    }
}

- (void)changeMediaWithUser:(NSString *)uid
                     camera:(BOOL)camera
                        mic:(BOOL)mic {
    if ([uid isEqualToString:self.liveRoomModel.anchorUserID]) {
        self.liveRoomModel.hostUserModel.camera = camera;
        self.liveRoomModel.hostUserModel.mic = mic;
        if (self.livePushStreamComponent.isConnect) {
            [self.livePushStreamComponent updateHostMic:mic camera:camera];
        }
        if (self.livePullStreamComponent.isConnect) {
            [self.livePullStreamComponent updateHostMic:mic camera:camera];
        }
    }
    if (self.addGuestsComponent.isConnect) {
        [self.addGuestsComponent updateGuestsCamera:camera uid:uid];
        [self.addGuestsComponent updateGuestsMic:mic uid:uid];
    }
    if (self.coHostComponent.isConnect) {
        [self.coHostComponent updateGuestsMic:mic uid:uid];
        [self.coHostComponent updateGuestsCamera:camera uid:uid];
    }
    if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
        self.currentUserModel.mic = mic;
        self.currentUserModel.camera = camera;
    }
}

- (void)addBeautyEffect:(LiveUserModel *)userModel {
    BOOL beautyEnable = NO;
    if (userModel.role == LiveUserRoleAudience) {
        if (userModel.status == LiveInteractStatusAudienceLink) {
            beautyEnable = YES;
        }
    } else if (userModel.role == LiveUserRoleHost) {
        beautyEnable = YES;
    } else {
        beautyEnable = NO;
    }
    if (beautyEnable) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // CV Simultaneous initialization and setting will cause deadlock, requiring delayed setting of special effects
            [self.beautyComponent resume];
        });
    }
}

- (void)clickBottomAddGuests:(LiveRoomBottomView *)bottomView
                  itemButton:(LiveRoomItemButton *_Nullable)itemButton
                  roleStatus:(BottomRoleStatus)roleStatus {
    if (self.coHostComponent.isConnect) {
        // Host is in your room. Failed to add a guest
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"host_connection_error")];
    } else {
        if (roleStatus == BottomRoleStatusAudience) {
            // Audience role
            if (self.currentUserModel.status == LiveInteractStatusApplying) {
                [self.addGuestsComponent showPending];
            } else {
                [self.addGuestsComponent showApply:self.currentUserModel
                                            hostID:self.liveRoomModel.anchorUserID];
            }
        } else if (roleStatus == BottomRoleStatusHost) {
            // Host role
            if ([bottomView getButtonTouchStatus:LiveRoomItemButtonStatePK]) {
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"request_sent_waiting")];
            } else {
                [self.addGuestsComponent showListWithSwitch:itemButton.isUnread
                                                      block:^(LiveAddGuestsDismissState state){

                                                      }];
            }
        } else if (roleStatus == BottomRoleStatusGuests) {
            // Guests role
            [self.mediaComponent show:LiveMediaStatusGuests
                            userModel:self.currentUserModel];
        } else {
            // error
        }
    }
}

- (void)clickBottomCoHost:(LiveRoomBottomView *)bottomView
               itemButton:(LiveRoomItemButton *_Nullable)itemButton
               roleStatus:(BottomRoleStatus)roleStatus {
    if (itemButton.touchStatus == LiveRoomItemTouchStatusClose) {
        // During PK
        [self.coHostComponent showDuringPK];
    } else if (itemButton.touchStatus == LiveRoomItemTouchStatusIng) {
        // Waiting for the response from the invited host
    } else {
        // show list view
        [self.coHostComponent showInviteList:^(LiveCoHostDismissState state){

        }];
    }
}

//- (void)showCloseAddGuests {
//    if ([self isHost]) {
//        __weak __typeof(self) wself = self;
//        AlertActionModel *alertModel = [[AlertActionModel alloc] init];
//        alertModel.title = LocalizedString(@"exit");
//        alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
//            if ([action.title isEqualToString:LocalizedString(@"exit")]) {
//                [wself ];
//            }
//        };
//
//        AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
//        alertCancelModel.title = LocalizedString(@"cancel");
//
//        NSString *message = [NSString stringWithFormat:LocalizedString(@"%@sure_stop_live"), @(self.addGuestsComponent.guestList.count).stringValue];
//        [[AlertActionManager shareAlertActionManager] showWithMessage:message actions:@[ alertCancelModel, alertModel ]];
//    } else {
//    }
//}

- (void)joinRoom {
    if ([self isHost]) {
        // The host creates a room, no need to join the room
        [self restoreRoomWithRoomInfoModel:self.liveRoomModel
                                 userModel:self.liveRoomModel.hostUserModel
                               rtcUserList:@[]];
    } else {
        // Audience need to join the room first
        [self loadDataWithJoinLiveRoom];
        [self.livePullStreamComponent open:self.liveRoomModel];
    }
}
- (void)restoreRoomWithRoomInfoModel:(LiveRoomInfoModel *)roomModel
                           userModel:(LiveUserModel *)userModel
                         rtcUserList:(NSArray<LiveUserModel *> *)rtcUserList {
    self.liveRoomModel = roomModel;
    self.currentUserModel = userModel;
    // Join RTS room

    [[LiveRTCManager shareRtc] joinLiveRoomByToken:roomModel.rtmToken
                                            roomID:roomModel.roomID
                                            userID:[LocalUserComponent userModel].uid];
    // Update UI layout
    [self addSubviewAndConstraints];
    self.hostAvatarView.hostUserModel = roomModel.hostUserModel;
    [self.peopleNumView updateTitleLabel:roomModel.audienceCount];
    [self updateLayoutToRole:userModel rtcUserList:rtcUserList];
    [self updatePullStatus:roomModel.hostUserModel.status
                 userCount:rtcUserList.count];
    [self changeMediaWithUser:roomModel.hostUserModel.uid
                       camera:roomModel.hostUserModel.camera
                          mic:roomModel.hostUserModel.mic];
    // Update Resolution
    [self loadDataWithupdateRes:self.currentUserModel];

    if ([self isHost]) {
        // Host join RTC room
        LiveNormalStreamConfig *config = [LiveNormalStreamConfig defaultConfig];
        config.rtmpUrl = self.streamPushUrl;
        self.linkSession.streamConfig = config;
        [self.linkSession startNormalStreaming];
    }
}

- (BOOL)isHost {
    return [self.liveRoomModel.anchorUserID isEqualToString:[LocalUserComponent userModel].uid];
}

- (void)hangUp {
    __weak __typeof(self) wself = self;
    if ([self isHost]) {
        // Host
        [LiveRTSManager liveFinishLive:self.liveRoomModel.roomID
                                 block:^(LiveEndLiveModel *endliveInfo, RTSACKModel *_Nonnull model) {
                                     __strong __typeof(wself) strongSelf = wself;
                                     if (!model.result) {
                                         /*When the anchor disconnect for 30s due to network issue, the server will close this room and
                                          send a liveOnFinishLive message, which can not be recevived at this moment. After we resume the
                                          network, we will call this api to close room, and server will give us a 421 code to identify this
                                          very condition, and we need to close live room manually by calling receivedLiveEnd:endLiveInfo.
                                         */
                                         if (model.code == 421) {
                                             [self receivedLiveEnd:@"0" endLiveInfo:[LiveEndLiveModel new]];
                                         } else {
                                             [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                         }
                                     } else {
                                         strongSelf.linkSession = nil;
                                     }
                                 }];
    } else {
        // Audience & Guests
        [[ToastComponent shareToastComponent] showLoading];
        [LiveRTSManager liveLeaveLiveRoom:self.liveRoomModel.roomID block:^(RTSACKModel *_Nonnull model) {
            __strong __typeof(wself) strongSelf = wself;
            if (strongSelf.hangUpBlock) {
                strongSelf.hangUpBlock(model.result);
            }
            [[ToastComponent shareToastComponent] dismiss];
            [wself navigationControllerPop];
        }];
    }
}

- (void)navigationControllerPop {
    UIViewController *jumpVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        NSString *vcName = @"LiveRoomListsViewController";
        if ([NSStringFromClass([vc class]) isEqualToString:vcName]) {
            jumpVC = vc;
            break;
        }
    }
    if (jumpVC) {
        [self.navigationController popToViewController:jumpVC animated:NO];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
- (void)addBgGradientLayer {
    UIColor *startColor = [UIColor colorFromHexString:@"#250214"];
    UIColor *endColor = [UIColor colorFromHexString:@"#0D0B53"];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    gradientLayer.colors = @[(__bridge id)[startColor colorWithAlphaComponent:1.0].CGColor,
                             (__bridge id)[endColor colorWithAlphaComponent:1.0].CGColor];
    gradientLayer.startPoint = CGPointMake(.0, .0);
    gradientLayer.endPoint = CGPointMake(.0, 1.0);
    [self.view.layer addSublayer:gradientLayer];
}

#pragma mark - Getter

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

- (LiveRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[LiveRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (BaseIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[BaseIMComponent alloc] initWithSuperView:self.view];
    }
    return _imComponent;
}

- (UIView *)liveView {
    if (!_liveView) {
        _liveView = [[UIView alloc] init];
    }
    return _liveView;
}

- (LiveCoHostComponent *)coHostComponent {
    if (!_coHostComponent) {
        _coHostComponent = [[LiveCoHostComponent alloc] initWithRoomID:self.liveRoomModel];
        _coHostComponent.delegate = self;
    }
    return _coHostComponent;
}

- (LiveAddGuestsComponent *)addGuestsComponent {
    if (!_addGuestsComponent) {
        _addGuestsComponent = [[LiveAddGuestsComponent alloc]
            initWithRoomID:self.liveRoomModel];
        _addGuestsComponent.delegate = self;
    }
    return _addGuestsComponent;
}

- (LivePushStreamComponent *)livePushStreamComponent {
    if (!_livePushStreamComponent) {
        _livePushStreamComponent = [[LivePushStreamComponent alloc]
            initWithSuperView:self.liveView
                    roomModel:self.liveRoomModel
                streamPushUrl:self.streamPushUrl];
    }
    return _livePushStreamComponent;
}

- (LivePullStreamComponent *)livePullStreamComponent {
    if (!_livePullStreamComponent) {
        _livePullStreamComponent = [[LivePullStreamComponent alloc] initWithSuperView:self.liveView];
        _livePullStreamComponent.delegate = self;
    }
    return _livePullStreamComponent;
}

- (LiveRoomSettingComponent *)settingComponent {
    if (!_settingComponent) {
        _settingComponent = [[LiveRoomSettingComponent alloc] initWithView:self.view];
    }
    return _settingComponent;
}

- (BytedEffectProtocol *)beautyComponent {
    if (!_beautyComponent) {
        _beautyComponent = [[BytedEffectProtocol alloc] initWithRTCEngineKit:[LiveRTCManager shareRtc].rtcEngineKit useCache:YES];
    }
    return _beautyComponent;
}

- (BaseButton *)closeLiveButton {
    if (!_closeLiveButton) {
        _closeLiveButton = [[BaseButton alloc] init];
        _closeLiveButton.backgroundColor = [UIColor clearColor];
        [_closeLiveButton addTarget:self action:@selector(closeLiveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeLiveButton;
}

- (LiveTextInputComponent *)inputComponent {
    if (!_inputComponent) {
        _inputComponent = [[LiveTextInputComponent alloc] init];
    }
    return _inputComponent;
}

- (LiveInformationComponent *)informationComponent {
    if (!_informationComponent) {
        _informationComponent = [[LiveInformationComponent alloc] initWithView:self.view];
    }
    return _informationComponent;
}

- (LiveMediaComponent *)mediaComponent {
    if (!_mediaComponent) {
        _mediaComponent = [[LiveMediaComponent alloc] init];
        _mediaComponent.delegate = self;
    }
    return _mediaComponent;
}

- (LiveSendGiftComponent *)sendGifgComponent {
    if (!_sendGifgComponent) {
        _sendGifgComponent = [[LiveSendGiftComponent alloc] initWithView:self.view];
    }
    return _sendGifgComponent;
}

- (LiveGiftEffectComponent *)giftEffectComponent {
    if (!_giftEffectComponent) {
        _giftEffectComponent = [[LiveGiftEffectComponent alloc] initWithView:self.view];
    }
    return _giftEffectComponent;
}

- (LiveSendLikeComponent *)sendLikeComponent {
    if (!_sendLikeComponent) {
        _sendLikeComponent = [[LiveSendLikeComponent alloc] initWithView:self.view];
    }
    return _sendLikeComponent;
}

#pragma mark - Gift

- (void)addImageAndTitleL:(UIButton *)button
                imageName:(NSString *)imageName
                  message:(NSString *)message {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:imageName bundleName:HomeBundleName];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(button.mas_width);
        make.centerX.top.equalTo(button);
    }];

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = message;
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.textColor = [UIColor whiteColor];
    [button addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(button);
    }];
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[LiveRTCManager shareRtc] leaveLiveRoom];
    [[LivePlayerManager sharePlayer] stopPull];
    [self.livePullStreamComponent close];
}

@end
