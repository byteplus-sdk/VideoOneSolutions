// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomViewController.h"
#import "KTVRoomViewController+SocketControl.h"
#import "KTVDownloadMusicComponent.h"
#import "KTVStaticView.h"
#import "KTVHostAvatarView.h"
#import "KTVRoomBottomView.h"
#import "KTVPeopleNumView.h"
#import "KTVSeatComponent.h"
#import "KTVMusicComponent.h"
#import "KTVTextInputComponent.h"
#import "KTVRoomUserListComponent.h"
#import "KTVPickSongComponent.h"
#import "KTVRTCManager.h"
#import "KTVRTSManager.h"
#import "NetworkingTool.h"

@interface KTVRoomViewController () <KTVRoomBottomViewDelegate, KTVRTCManagerDelegate, KTVSeatDelegate, MusicComponentDelegate, KTVPickSongComponentDelegate>

@property (nonatomic, strong) KTVStaticView *staticView;
@property (nonatomic, strong) KTVHostAvatarView *hostAvatarView;
@property (nonatomic, strong) KTVRoomBottomView *bottomView;
@property (nonatomic, strong) KTVMusicComponent *musicComponent;
@property (nonatomic, strong) KTVTextInputComponent *textInputComponent;
@property (nonatomic, strong) KTVRoomUserListComponent *userListComponent;
@property (nonatomic, strong) BaseIMComponent *imComponent;
@property (nonatomic, strong) KTVSeatComponent *seatComponent;
@property (nonatomic, strong) KTVPickSongComponent *pickSongComponent;
@property (nonatomic, strong) KTVRoomModel *roomModel;
@property (nonatomic, strong) KTVUserModel *hostUserModel;
@property (nonatomic, strong) KTVSongModel *songModel;
@property (nonatomic, copy) NSString *rtcToken;

@property (nonatomic, strong) UIView *seatContentView;

@end

@implementation KTVRoomViewController

- (instancetype)initWithRoomModel:(KTVRoomModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (instancetype)initWithRoomModel:(KTVRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(KTVUserModel *)hostUserModel {
    self = [super init];
    if (self) {
        _hostUserModel = hostUserModel;
        _roomModel = roomModel;
        _rtcToken = rtcToken;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.view.backgroundColor = [UIColor colorFromHexString:@"#394254"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearRedNotification) name:KClearRedNotification object:nil];
    
    [self addSocketListener];
    [self addSubviewAndConstraints];
    [self joinRoom];
    
    __weak __typeof(self) wself = self;
    self.staticView.clickEndBlock = ^{
        [wself endLive];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notification

- (void)reconnectKTVRoom {
    __weak typeof(self) weakSelf = self;
    [KTVRTSManager reconnect:self.roomModel.roomID
                       block:^(NSString * _Nonnull RTCToken,
                               KTVRoomModel * _Nonnull roomModel,
                               KTVUserModel * _Nonnull userModel,
                               KTVUserModel * _Nonnull hostUserModel,
                               KTVSongModel * _Nonnull songModel,
                               NSArray<KTVSeatModel *> * _Nonnull seatList,
                               RTSACKModel * _Nonnull model) {
        // Reconnect
        if (model.result) {
            [weakSelf updateRoomViewWithData:RTCToken
                                   roomModel:roomModel
                                   userModel:userModel
                               hostUserModel:hostUserModel
                                    seatList:seatList
                                   songModel:songModel
                                 isReconnect:YES];
            
            for (KTVSeatModel *seatModel in seatList) {
                if ([seatModel.userModel.uid isEqualToString:userModel.uid]) {
                    // Reconnect after disconnection, I need to turn on the microphone to collect
                    [[KTVRTCManager shareRtc] enableLocalAudio:(userModel.mic == KTVUserMicOn) ? YES : NO];
                    break;
                }
            }
        } else if (model.code == RTSStatusCodeUserIsInactive ||
                   model.code == RTSStatusCodeRoomDisbanded ||
                   model.code == RTSStatusCodeUserNotFound) {
            [weakSelf hangUp:NO];
        }
    }];
}

- (void)clearRedNotification {
    [self.bottomView updateButtonStatus:KTVRoomBottomStatusPhone isRed:NO];
    [self.userListComponent updateWithRed:NO];
}

#pragma mark - SocketControl

// The audience cannot receive a callback when they enter the room for the first time because they have not yet joined the room
- (void)receivedJoinUser:(KTVUserModel *)userModel
                   count:(NSInteger)count {
    NSString *message = [NSString stringWithFormat:@"%@ %@", userModel.name, LocalizedString(@"im_label_join_room")];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
    [self.userListComponent update];
}

- (void)receivedLeaveUser:(KTVUserModel *)userModel
                    count:(NSInteger)count {
    NSString *message = [NSString stringWithFormat:@"%@ %@", userModel.name, LocalizedString(@"im_label_leave_room")];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
    [self.userListComponent update];
}

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomModel.roomID]) {
        return;
    }
    [self hangUp:NO];
    if (type == 3) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_false_violates_rules") delay:0.8];
    }
    else if (type == 2 && [self isHost]) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_false_time_out") delay:0.8];
    } else {
        if (![self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_false_live_end") delay:0.8];
        }
    }
}

- (void)receivedJoinInteractWithUser:(KTVUserModel *)userModel
                              seatID:(NSString *)seatID {
    KTVSeatModel *seatModel = [[KTVSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatComponent addSeatModel:seatModel];
    [self.userListComponent update];
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        [self.bottomView updateBottomLists:userModel];
        // RTC Start Audio Capture
        [[KTVRTCManager shareRtc] enableLocalAudio:YES];
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_become_guest")];
        [self.musicComponent updateUserModel:userModel];
    }
    [self.seatComponent dismissSheetViewWithSeatId:seatID];
    
    //IM
    NSString *message = [NSString stringWithFormat:LocalizedString(@"toast_become_guest_%@"), userModel.name];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
}

- (void)receivedLeaveInteractWithUser:(KTVUserModel *)userModel
                               seatID:(NSString *)seatID
                                 type:(NSInteger)type {
    [self.seatComponent removeUserModel:userModel];
    [self.userListComponent update];
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        [self.bottomView updateBottomLists:userModel];
        // RTC Stop Audio Capture
        [[KTVRTCManager shareRtc] enableLocalAudio:NO];
        [self.musicComponent updateUserModel:userModel];
        [self.pickSongComponent dismissView];
        [self.seatComponent dismissSheetView];
        
        if (type == 1) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_passive_audience")];
        } else if (type == 2) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_become_audience")];
        }
    }
    [self.seatComponent dismissSheetViewWithSeatId:seatID];
    
    //IM
    NSString *message = [NSString stringWithFormat:LocalizedString(@"toast_become_audience_%@"),userModel.name];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
}

- (void)receivedSeatStatusChange:(NSString *)seatID
                            type:(NSInteger)type {
    KTVSeatModel *seatModel = [[KTVSeatModel alloc] init];
    seatModel.status = type;
    seatModel.userModel = nil;
    seatModel.index = seatID.integerValue;
    [self.seatComponent updateSeatModel:seatModel];
}

- (void)receivedMediaStatusChangeWithUser:(KTVUserModel *)userModel
                                   seatID:(NSString *)seatID
                                      mic:(NSInteger)mic {
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        [self.bottomView updateButtonStatus:KTVRoomBottomStatusLocalMic
                                   isSelect:!mic];
    }
    KTVSeatModel *seatModel = [[KTVSeatModel alloc] init];
    seatModel.status = 1;
    seatModel.userModel = userModel;
    seatModel.index = seatID.integerValue;
    [self.seatComponent updateSeatModel:seatModel];
    if ([userModel.uid isEqualToString:self.roomModel.hostUid]) {
        [self.hostAvatarView updateHostMic:mic];
    }
    if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        // RTC Mute/Unmute Audio Capture
        [[KTVRTCManager shareRtc] muteLocalAudio:!mic];
    }
}

- (void)receivedMessageWithUser:(KTVUserModel *)userModel
                        message:(NSString *)message {
    if (![userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        BaseIMModel *model = [[BaseIMModel alloc] init];
        model.userID = userModel.uid;
        model.userName = userModel.name;
        model.message = message;
        [self updateIMModel:model];
        [self.imComponent addIM:model];
    }
}

- (void)receivedInviteInteractWithUser:(KTVUserModel *)hostUserModel
                                seatID:(NSString *)seatID {
    [self.seatComponent dismissSheetView];
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"button_alert_accept");
    AlertActionModel *cancelModel = [[AlertActionModel alloc] init];
    cancelModel.title = LocalizedString(@"button_alert_reject");
    [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"toast_receive_invite_guest") actions:@[cancelModel, alertModel]];
    
    __weak __typeof(self) wself = self;
    alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"button_alert_accept")]) {
            [wself loadDataWithReplyInvite:1];
        }
    };
    cancelModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"button_alert_reject")]) {
            [wself loadDataWithReplyInvite:2];
        }
    };
}

- (void)receivedApplyInteractWithUser:(KTVUserModel *)userModel
                               seatID:(NSString *)seatID {
    if ([self isHost]) {
        [self.bottomView updateButtonStatus:KTVRoomBottomStatusPhone isRed:YES];
        [self.userListComponent updateWithRed:YES];
        [self.userListComponent update];
    }
}

- (void)receivedInviteResultWithUser:(KTVUserModel *)hostUserModel
                               reply:(NSInteger)reply {
    if ([self isHost] && reply == 2) {
        NSString *message = [NSString stringWithFormat:LocalizedString(@"toast_receive_invitation_received_%@"), hostUserModel.name];
        [[ToastComponent shareToastComponent] showWithMessage:message];
        [self.userListComponent update];
    }
}

- (void)receivedMediaOperatWithUid:(NSInteger)mic {
    [KTVRTSManager updateMediaStatus:self.roomModel.roomID
                                              mic:mic
                               block:^(RTSACKModel * _Nonnull model) {
        
    }];
    if (mic) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_receive_unmute")];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_receive_mute")];
    }
}

- (void)receivedClearUserWithUid:(NSString *)uid {
    [self hangUp:NO];
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_receive_clear_user") delay:0.8];
}

- (void)hangUp:(BOOL)isServer {
    if (isServer) {
        // socket api
        if ([self isHost]) {
            [KTVRTSManager finishLive:self.roomModel.roomID];
        } else {
            [KTVRTSManager leaveLiveRoom:self.roomModel.roomID];
        }
    }
    // sdk api
    [[KTVRTCManager shareRtc] leaveChannel];
    
    [[KTVRTCManager shareRtc] enableLocalAudio:NO];
    // ui
    [self navigationControllerPop];
}

- (void)receivedPickedSong:(KTVSongModel *)songModel {
    [self.pickSongComponent updatePickedSongList];
}

- (void)receivedStartSingSong:(KTVSongModel *)songModel {
    [self.musicComponent startSingWithSongModel:songModel];
    [self.pickSongComponent updatePickedSongList];
    [self.seatComponent updateCurrentSongModel:songModel];
    [self.hostAvatarView updateCurrentSongModel:songModel];
}

- (void)receivedFinishSingSong:(NSInteger)score
                 nextSongModel:(KTVSongModel *)nextSongModel
                  curSongModel:(KTVSongModel *)curSongModel {
    [self.musicComponent showSongEndSongModel:nextSongModel
                                 curSongModel:curSongModel
                                        score:score];
    [self.pickSongComponent updatePickedSongList];
}

#pragma mark - Load Data

- (void)loadDataWithJoinRoom {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [KTVRTSManager joinLiveRoom:self.roomModel.roomID
                       userName:[LocalUserComponent userModel].name
                          block:^(NSString * _Nonnull RTCToken,
                                  KTVRoomModel * _Nonnull roomModel,
                                  KTVUserModel * _Nonnull userModel,
                                  KTVUserModel * _Nonnull hostUserModel,
                                  KTVSongModel * _Nonnull songModel,
                                  NSArray<KTVSeatModel *> * _Nonnull seatList,
                                  RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (NOEmptyStr(roomModel.roomID)) {
            [wself updateRoomViewWithData:RTCToken
                                roomModel:roomModel
                                userModel:userModel
                            hostUserModel:hostUserModel
                                 seatList:seatList
                                songModel:songModel
                              isReconnect:NO];
        } else {
            AlertActionModel *alertModel = [[AlertActionModel alloc] init];
            alertModel.title = LocalizedString(@"ok");
            alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
                if ([action.title isEqualToString:LocalizedString(@"ok")]) {
                    [wself hangUp:NO];
                }
            };
            [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"toast_false_join_room") actions:@[alertModel]];
        }
    }];
}

#pragma mark - KTVPickSongComponentDelegate
- (void)ktvPickSongComponent:(KTVPickSongComponent *)component pickedSongCountChanged:(NSInteger)count {
    [self.bottomView updatePickedSongCount:count];
}

#pragma mark - KTVRoomBottomViewDelegate

- (void)KTVRoomBottomView:(KTVRoomBottomView *_Nonnull)KTVRoomBottomView
                     itemButton:(KTVRoomItemButton *_Nullable)itemButton
                didSelectStatus:(KTVRoomBottomStatus)status {
    if (status == KTVRoomBottomStatusInput) {
        [self.textInputComponent showWithRoomModel:self.roomModel];
        __weak __typeof(self) wself = self;
        self.textInputComponent.clickSenderBlock = ^(NSString * _Nonnull text) {
            BaseIMModel *model = [[BaseIMModel alloc] init];
            model.userID = [LocalUserComponent userModel].uid;
            model.userName = [LocalUserComponent userModel].name;
            model.message = text;
            [wself updateIMModel:model];
            [wself.imComponent addIM:model];
        };
    } else if (status == KTVRoomBottomStatusPhone) {
        [self.userListComponent showRoomModel:self.roomModel
                                        seatID:@"-1"
                                  dismissBlock:^{
            
        }];
    } else if (status == KTVRoomBottomStatusPickSong) {
        [self showPickSongView];
    }
}

#pragma mark - KTVSeatDelegate

- (void)seatComponent:(KTVSeatComponent *)seatComponent
          clickButton:(KTVSeatModel *)seatModel
          sheetStatus:(KTVSheetStatus)sheetStatus {
    if (sheetStatus == KTVSheetStatusInvite) {
        [self.userListComponent showRoomModel:self.roomModel
                                        seatID:[NSString stringWithFormat:@"%ld", (long)seatModel.index]
                                  dismissBlock:^{
            
        }];
    }
}

#pragma mark - KTVRTCManagerDelegate

- (void)KTVRTCManager:(KTVRTCManager *)KTVRTCManager onRoomStateChanged:(RTCJoinModel *)joinModel uid:(NSString *)uid {
    if (joinModel.errorCode == 0 && joinModel.joinType == 0) {
        __weak __typeof(self) wself = self;
        [self.pickSongComponent requestMusicListWithBlock:^(NSArray<KTVSongModel *> *musicList) {
            [[KTVDownloadMusicComponent shared] updateOnlineMusicList:musicList];
            [wself.musicComponent startSingWithSongModel:wself.songModel];
        }];
    } else if (joinModel.errorCode == 0 && joinModel.joinType != 0) {
        [self reconnectKTVRoom];
    }
}

- (void)KTVRTCManager:(KTVRTCManager *)KTVRTCManager changeParamInfo:(KTVRoomParamInfoModel *)model {
    [self.staticView updateParamInfoModel:model];
}

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager reportAllAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo {
    if (volumeInfo.count > 0) {
        [self.hostAvatarView updateHostVolume:volumeInfo[self.hostUserModel.uid]];
        [self.seatComponent updateSeatVolume:volumeInfo];
    }
}

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager onStreamSyncInfoReceived:(nonnull NSDictionary *)infoDic {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent updateCurrentSongTime:infoDic];
    });
}

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager songEnds:(BOOL)result {
    [self.musicComponent stopSong];
}

- (void)KTVRTCManager:(KTVRTCManager *_Nonnull)KTVRTCManager onAudioMixingPlayingProgress:(NSInteger)progress {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent sendSongTime:progress];
    });
}

- (void)KTVRTCManagerOnAudioRouteChanged:(KTVRTCManager *)KTVRTCManager {
    [self.musicComponent updateAudioRouteChanged];
}

#pragma mark - MusicComponentDelegate

- (void)musicComponent:(KTVMusicComponent *)musicComponent clickPlayMusic:(BOOL)isClick {
    [self showPickSongView];
}

- (void)musicComponent:(KTVMusicComponent *)musicComponent clickOpenSongList:(BOOL)isClick {
    [self showSongListView];
}

#pragma mark - Network request

- (void)loadDataWithReplyInvite:(NSInteger)type {
    [KTVRTSManager replyInvite:self.roomModel.roomID
                                      reply:type
                                      block:^(RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}

#pragma mark - Private Action

- (void)joinRoom {
    if (IsEmptyStr(self.hostUserModel.uid)) {
        [self loadDataWithJoinRoom];
        self.staticView.roomModel = self.roomModel;
    } else {
        [self updateRoomViewWithData:self.rtcToken
                           roomModel:self.roomModel
                           userModel:self.hostUserModel
                       hostUserModel:self.hostUserModel
                            seatList:[self getDefaultSeatDataList]
                           songModel:nil
                         isReconnect:NO];
    }
}

- (void)updateRoomViewWithData:(NSString *)rtcToken
                     roomModel:(KTVRoomModel *)roomModel
                     userModel:(KTVUserModel *)userModel
                 hostUserModel:(KTVUserModel *)hostUserModel
                      seatList:(NSArray<KTVSeatModel *> *)seatList
                     songModel:(KTVSongModel *)songModel
                   isReconnect:(BOOL)isReconnect {
    _hostUserModel = hostUserModel;
    _roomModel = roomModel;
    _rtcToken = rtcToken;
    _songModel = songModel;
    
    [KTVRTCManager shareRtc].delegate = self;
    [[KTVRTCManager shareRtc] joinChannelWithToken:rtcToken
                                            roomID:self.roomModel.roomID
                                               uid:[LocalUserComponent userModel].uid];
    if (userModel.userRole == KTVUserRoleHost) {
        [[KTVRTCManager shareRtc] enableLocalAudio:(userModel.mic == KTVUserMicOn) ? YES : NO];
    }
    self.hostAvatarView.userModel = self.hostUserModel;
    self.staticView.roomModel = self.roomModel;
    [self.bottomView updateBottomLists:userModel];
    [self.seatComponent showSeatView:seatList loginUserModel:userModel];
    [self.musicComponent updateUserModel:userModel];
    [self.seatComponent updateCurrentSongModel:songModel];
    [self.hostAvatarView updateCurrentSongModel:songModel];
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.staticView];
    [self.staticView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.seatContentView];
    [self.seatContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(54);
        make.top.mas_equalTo(356 + [DeviceInforTool getSafeAreaInsets].bottom);
    }];
    
    CGFloat space = (SCREEN_WIDTH - 32 * 7 - 1)/9;
    
    [self.seatContentView addSubview:self.hostAvatarView];
    [self.hostAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 54));
        make.top.bottom.equalTo(self.seatContentView);
        make.left.equalTo(self.seatContentView).offset(space);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.27];
    [self.seatContentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hostAvatarView.mas_right).offset(space);
        make.centerY.equalTo(self.hostAvatarView);
        make.size.mas_equalTo(CGSizeMake(1, 30));
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([DeviceInforTool getVirtualHomeHeight] + 36);
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.bottom.equalTo(self.view);
    }];
    
    [self musicComponent];
    [self imComponent];
    [self textInputComponent];
    [self pickSongComponent];
}

- (void)showEndView {
    __weak __typeof(self) wself = self;
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"button_alert_live_end");
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"button_alert_live_end")]) {
            [wself hangUp:YES];
        }
    };
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"cancel");
    NSString *message = LocalizedString(@"label_alert_live_end");
    [[AlertActionManager shareAlertActionManager] showWithMessage:message actions:@[ alertCancelModel, alertModel ]];
}

- (void)navigationControllerPop {
    UIViewController *jumpVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"KTVRoomListsViewController"]) {
            jumpVC = vc;
            break;
        }
    }
    if (jumpVC) {
        [self.navigationController popToViewController:jumpVC animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isHost {
    return [self.roomModel.hostUid isEqualToString:[LocalUserComponent userModel].uid];
}

- (void)updateIMModel:(BaseIMModel *)imModel {
    if ([imModel.userID isEqualToString:self.roomModel.hostUid]) {
        imModel.iconImage = [UIImage imageNamed:@"im_host" bundleName:HomeBundleName];
    }
}

- (NSArray *)getDefaultSeatDataList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < 8; i++) {
        KTVSeatModel *seatModel = [[KTVSeatModel alloc] init];
        seatModel.status = 1;
        seatModel.index = i + 1;
        [list addObject:seatModel];
    }
    return [list copy];
}

- (void)showPickSongView {
    [self.pickSongComponent show];
}

- (void)showSongListView {
    [self.pickSongComponent showPickedSongList];
}

- (void)endLive {
    if ([self isHost]) {
        [self showEndView];
    } else {
        [self hangUp:YES];
    }
}

#pragma mark - Getter

- (KTVTextInputComponent *)textInputComponent {
    if (!_textInputComponent) {
        _textInputComponent = [[KTVTextInputComponent alloc] init];
    }
    return _textInputComponent;
}

- (KTVStaticView *)staticView {
    if (!_staticView) {
        _staticView = [[KTVStaticView alloc] init];
    }
    return _staticView;
}

- (KTVHostAvatarView *)hostAvatarView {
    if (!_hostAvatarView) {
        _hostAvatarView = [[KTVHostAvatarView alloc] init];
    }
    return _hostAvatarView;
}

- (KTVSeatComponent *)seatComponent {
    if (!_seatComponent) {
        _seatComponent = [[KTVSeatComponent alloc] initWithSuperView:self.seatContentView];
        _seatComponent.delegate = self;
    }
    return _seatComponent;
}

- (KTVRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[KTVRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (KTVRoomUserListComponent *)userListComponent {
    if (!_userListComponent) {
        _userListComponent = [[KTVRoomUserListComponent alloc] init];
    }
    return _userListComponent;
}

- (BaseIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[BaseIMComponent alloc] initWithSuperView:self.view];
        [_imComponent remakeTopConstraintValue:496];
    }
    return _imComponent;
}

- (KTVMusicComponent *)musicComponent {
    if (!_musicComponent) {
        _musicComponent = [[KTVMusicComponent alloc] initWithSuperView:self.view
                                                                  roomID:self.roomModel.roomID];
        _musicComponent.delegate = self;
    }
    return _musicComponent;
}

- (void)dealloc {
    [self.musicComponent dismissTuningPanel];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[AlertActionManager shareAlertActionManager] dismiss:^{
        
    }];
}

- (UIView *)seatContentView {
    if (!_seatContentView) {
        _seatContentView = [[UIView alloc] init];
    }
    return _seatContentView;
}

- (KTVPickSongComponent *)pickSongComponent {
    if (!_pickSongComponent) {
        _pickSongComponent = [[KTVPickSongComponent alloc] initWithSuperView:self.view roomID:self.roomModel.roomID];
        _pickSongComponent.delegate = self;
    }
    return _pickSongComponent;
}

@end
