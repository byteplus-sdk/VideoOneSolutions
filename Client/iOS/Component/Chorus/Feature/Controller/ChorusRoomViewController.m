// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusRoomViewController.h"
#import "ChorusRoomViewController+SocketControl.h"
#import "ChorusStaticView.h"
#import "ChorusRoomBottomView.h"
#import "ChorusPeopleNumView.h"
#import "ChorusMusicComponent.h"
#import "ChorusTextInputComponent.h"
#import "BaseIMComponent.h"
#import "ChorusDownloadMusicComponent.h"
#import "ChorusPickSongComponent.h"
#import "ChorusRTCManager.h"
#import "ChorusRTSManager.h"
#import "ChorusDataManager.h"

@interface ChorusRoomViewController ()
<
ChorusRoomBottomViewDelegate,
ChorusRTCManagerDelegate,
ChorusPickSongComponentDelegate,
ChorusMusicComponentDelegate
>

@property (nonatomic, strong) ChorusStaticView *staticView;
@property (nonatomic, strong) ChorusRoomBottomView *bottomView;
@property (nonatomic, strong) ChorusMusicComponent *musicComponent;
@property (nonatomic, strong) ChorusTextInputComponent *textInputComponent;
@property (nonatomic, strong) BaseIMComponent *imComponent;
@property (nonatomic, strong) ChorusPickSongComponent *pickSongComponent;
@property (nonatomic, strong) ChorusRoomModel *roomModel;
@property (nonatomic, strong) ChorusUserModel *hostUserModel;
@property (nonatomic, strong) ChorusSongModel *songModel;
@property (nonatomic, strong) ChorusSongModel *nextSongModel;
@property (nonatomic, copy) NSString *rtcToken;

@end

@implementation ChorusRoomViewController

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (instancetype)initWithRoomModel:(ChorusRoomModel *)roomModel
                         rtcToken:(NSString *)rtcToken
                    hostUserModel:(ChorusUserModel *)hostUserModel {
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
    
    [ChorusDataManager shared].roomModel = self.roomModel;
    
    [self addSocketListener];
    [self addSubviewAndConstraints];
    [self joinRoom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - SocketControl

- (void)receivedJoinUser:(ChorusUserModel *)userModel
                   count:(NSInteger)count {
    NSString *message = [NSString stringWithFormat:@"%@ %@", userModel.name, LocalizedString(@"im_label_join_room")];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
}

- (void)receivedLeaveUser:(ChorusUserModel *)userModel
                    count:(NSInteger)count {
    NSString *message = [NSString stringWithFormat:@"%@ %@", userModel.name, LocalizedString(@"im_label_leave_room")];
    BaseIMModel *model = [[BaseIMModel alloc] init];
    model.userID = userModel.uid;
    model.message = message;
    [self updateIMModel:model];
    [self.imComponent addIM:model];
    [self.staticView updatePeopleNum:count];
}

- (void)receivedFinishLive:(NSInteger)type roomID:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomModel.roomID]) {
        return;
    }
    [self hangUp:NO];
    if (type == 3) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_close_room_error_violation") delay:0.8];
    }
    else if (type == 2 && [self isHost]) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_close_room_error_time") delay:0.8];
    } else {
        if (![self isHost]) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_close_room_error_default") delay:0.8];
        }
    }
}

- (void)receivedMessageWithUser:(ChorusUserModel *)userModel
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

- (void)hangUp:(BOOL)isServer {
    if (isServer) {
        if ([self isHost]) {
            [ChorusRTSManager finishLive:self.roomModel.roomID];
        } else {
            [ChorusRTSManager leaveLiveRoom:self.roomModel.roomID];
        }
    }
    [[ChorusRTCManager shareRtc] leaveChannel];
    [self navigationControllerPop];
}

- (void)receivedPickedSong:(ChorusSongModel *)songModel {
    [self.pickSongComponent updatePickedSongList];
}
- (void)receivedPrepareStartSingSong:(ChorusSongModel *)songModel
                 leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel {
    [[ChorusDataManager shared] resetDataManager];
    [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:NO];
    [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
    [[ChorusRTCManager shareRtc] stopSinging];
    
    [ChorusDataManager shared].currentSongModel = songModel;
    [ChorusDataManager shared].leadSingerUserModel = leadSingerUserModel;

    
    if ([ChorusDataManager shared].isLeadSinger) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }
    
    [self.musicComponent prepareStartSingSong:songModel
                           leadSingerUserModel:leadSingerUserModel];
    [self.pickSongComponent updatePickedSongList];
    [self.bottomView updateBottomLists];
    [self.bottomView updateBottomStatus:ChorusRoomBottomStatusLocalMic
                               isActive:![ChorusRTCManager shareRtc].isMicrophoneOpen];
}
- (void)receivedReallyStartSingSong:(ChorusSongModel *)songModel
                leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
                 succentorUserModel:(ChorusUserModel *_Nullable)succentorUserModel {
    [ChorusDataManager shared].succentorUserModel = succentorUserModel;
    
    if ([ChorusDataManager shared].isSuccentor) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }
    
    [self.musicComponent reallyStartSingSong:songModel];
    [self.pickSongComponent updatePickedSongList];
    [self.bottomView updateBottomLists];
    [self.bottomView updateBottomStatus:ChorusRoomBottomStatusLocalMic
                               isActive:![ChorusRTCManager shareRtc].isMicrophoneOpen];
}

- (void)receivedFinishSingSong:(NSInteger)score nextSongModel:(ChorusSongModel *)nextSongModel {
    [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:NO];
    [self.musicComponent showSongEndWithNextSongModel:nextSongModel];
    [self.pickSongComponent updatePickedSongList];
    [[ChorusRTCManager shareRtc] enableEarMonitor:NO];
    [[ChorusRTCManager shareRtc] stopSinging];
    
    [[ChorusDataManager shared] resetDataManager];
    [self.bottomView updateBottomLists];
}

#pragma mark - Load Data

- (void)loadDataWithJoinRoom {
    __weak typeof(self) weakSelf = self;
    [ChorusRTSManager joinLiveRoom:self.roomModel.roomID
                              userName:[LocalUserComponent userModel].name
                             block:^(NSString * _Nonnull RTCToken,
                                     ChorusRoomModel * _Nonnull roomModel,
                                     ChorusUserModel * _Nonnull userModel,
                                     ChorusUserModel * _Nonnull hostUserModel,
                                     ChorusSongModel * _Nullable songModel,
                                     ChorusUserModel * _Nullable leadSingerUserModel,
                                     ChorusUserModel * _Nullable succentorUserModel,
                                     ChorusSongModel * _Nullable nextSongModel,
                                     RTSACKModel * _Nonnull model) {
 
        if (NOEmptyStr(roomModel.roomID)) {
            [weakSelf updateRoomViewWithData:RTCToken
                                   roomModel:roomModel
                                   userModel:userModel
                               hostUserModel:hostUserModel
                                   songModel:songModel
                         leadSingerUserModel:leadSingerUserModel
                          succentorUserModel:succentorUserModel
                               nextSongModel:nextSongModel
                                 isReconnect:NO];
        } else {
            AlertActionModel *alertModel = [[AlertActionModel alloc] init];
            alertModel.title = LocalizedString(@"chorus_button_confirm");
            alertModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
                if ([action.title isEqualToString:LocalizedString(@"chorus_button_confirm")]) {
                    [weakSelf hangUp:NO];
                }
            };
            [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"toast_join_room_error") actions:@[alertModel]];
        }
    }];
}

#pragma mark - ChorusMusicComponentDelegate

- (void)musicComponent:(ChorusMusicComponent *)musicComponent
     clickOpenSongList:(BOOL)isClick {
    [self.pickSongComponent showPickedSongList];
}

#pragma mark - ChorusPickSongComponentDelegate

- (void)ChorusPickSongComponent:(ChorusPickSongComponent *)component pickedSongCountChanged:(NSInteger)count {
    [self.bottomView updatePickedSongCount:count];
}

#pragma mark - ChorusRoomBottomViewDelegate

- (void)chorusRoomBottomView:(ChorusRoomBottomView *_Nonnull)ChorusRoomBottomView
                     itemButton:(ChorusRoomItemButton *_Nullable)itemButton
                didSelectStatus:(ChorusRoomBottomStatus)status {
    if (status == ChorusRoomBottomStatusInput) {
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
    }
    else if (status == ChorusRoomBottomStatusPickSong) {
        [self showPickSongView];
    }
}

#pragma mark - ChorusRTCManagerDelegate

- (void)chorusRTCManager:(ChorusRTCManager *)manager onRoomStateChanged:(RTCJoinModel *)joinModel {
    if (joinModel.errorCode == 0 && joinModel.joinType == 0) {
        __weak __typeof(self) wself = self;
        [self.pickSongComponent requestMusicListWithBlock:^(NSArray<ChorusSongModel *> * _Nonnull musicList) {
            [wself roomDataRecovery:musicList];
        }];
    } else if (joinModel.errorCode == 0 && joinModel.joinType != 0) {
        [self reconnectRoom];
    }
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onStreamSyncInfoReceived:(NSString *)json {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent updateCurrentSongTime:json];
    });
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onSingEnded:(BOOL)result {
    [self.musicComponent stopSong];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onAudioMixingPlayingProgress:(NSInteger)progress {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.musicComponent sendSongTime:progress];
    });
}

- (void)chorusRTCManager:(ChorusRTCManager *)chorusRTCManager onNetworkQualityStatus:(ChorusNetworkQualityStatus)status userID:(NSString *)userID {
    [self.musicComponent updateNetworkQuality:status uid:userID];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onFirstVideoFrameRenderedWithUserID:(NSString *)uid {
    [self.musicComponent updateFirstVideoFrameRenderedWithUid:uid];
}

- (void)chorusRTCManager:(ChorusRTCManager *_Nonnull)chorusRTCManager onReportUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *_Nonnull)volumeInfo {
    [self.musicComponent updateUserAudioVolume:volumeInfo];
}

- (void)chorusRTCManagerOnAudioRouteChanged:(ChorusRTCManager *)chorusRTCManager {
    [self.musicComponent updateAudioRouteChanged];
}

#pragma mark - Private Action

- (void)roomDataRecovery:(NSArray<ChorusSongModel *> *)musicList {
    [[ChorusDownloadMusicComponent shared] updateOnlineMusicList:musicList];
    if (([ChorusDataManager shared].isLeadSinger || 
         [ChorusDataManager shared].isSuccentor) &&
        self.songModel.singStatus != ChorusSongModelSingStatusFinish) {
        [[ChorusRTCManager shareRtc] switchIdentifyBecomeSinger:YES];
    }

    if (self.songModel) {
        if (self.songModel.singStatus == ChorusSongModelSingStatusWaiting) {
            [self.musicComponent prepareStartSingSong:self.songModel
                                  leadSingerUserModel:nil];
        } else if (self.songModel.singStatus == ChorusSongModelSingStatusSinging) {
            [self.musicComponent prepareMaterialsWithSongModel:self.songModel];
            [self.musicComponent reallyStartSingSong:self.songModel];
        } else if (self.songModel.singStatus == ChorusSongModelSingStatusFinish) {
            [[ChorusDataManager shared] resetDataManager];
            [self.musicComponent showSongEndWithNextSongModel:self.nextSongModel];
            [self.bottomView updateBottomLists];
        }
    }
}

- (void)reconnectRoom {
    __weak typeof(self) weakSelf = self;
    NSString *roomID = self.roomModel.roomID;
    NSAssert(roomID, @"roomID is nil");
    [ChorusRTSManager reconnect:roomID
                          block:^(NSString * _Nonnull RTCToken,
                                  ChorusRoomModel * _Nonnull roomModel,
                                  ChorusUserModel * _Nonnull userModel,
                                  ChorusUserModel * _Nonnull hostUserModel,
                                  ChorusSongModel * _Nonnull songModel,
                                  ChorusUserModel * _Nonnull leadSingerUserModel,
                                  ChorusUserModel * _Nonnull succentorUserModel,
                                  ChorusSongModel * _Nonnull nextSongModel,
                                  NSInteger audienceCount,
                                  RTSACKModel * _Nonnull model) {
        if (model.result) {
            [weakSelf updateRoomViewWithData:RTCToken
                                   roomModel:roomModel
                                   userModel:userModel
                               hostUserModel:hostUserModel
                                   songModel:songModel
                         leadSingerUserModel:leadSingerUserModel
                          succentorUserModel:succentorUserModel
                               nextSongModel:nextSongModel
                                 isReconnect:YES];
        } else if (model.code == RTSStatusCodeUserIsInactive ||
                   model.code == RTSStatusCodeRoomDisbanded ||
                   model.code == RTSStatusCodeUserNotFound) {
            [weakSelf hangUp:YES];
            [[ToastComponent shareToastComponent] showWithMessage:model.message delay:0.8];
        }
    }];
}

- (void)joinRoom {
    if (IsEmptyStr(self.hostUserModel.uid)) {
        [self loadDataWithJoinRoom];
        self.staticView.roomModel = self.roomModel;
    } else {
        [self updateRoomViewWithData:self.rtcToken
                           roomModel:self.roomModel
                           userModel:self.hostUserModel
                       hostUserModel:self.hostUserModel
                           songModel:nil
                 leadSingerUserModel:nil
                  succentorUserModel:nil
                       nextSongModel:nil
                         isReconnect:NO];
    }
}

- (void)updateRoomViewWithData:(NSString *)rtcToken
                     roomModel:(ChorusRoomModel *)roomModel
                     userModel:(ChorusUserModel *)userModel
                 hostUserModel:(ChorusUserModel *)hostUserModel
                     songModel:(ChorusSongModel *)songModel
           leadSingerUserModel:(ChorusUserModel *)leadSingerUserModel
            succentorUserModel:(ChorusUserModel *)succentorUserModel
                 nextSongModel:(ChorusSongModel *)nextSongModel
                   isReconnect:(BOOL)isReconnect {
    self.hostUserModel = hostUserModel;
    self.roomModel = roomModel;
    self.rtcToken = rtcToken;
    self.songModel = songModel;
    self.nextSongModel = nextSongModel;
    
    [ChorusRTCManager shareRtc].delegate = self;
    if (!isReconnect) {
        [[ChorusRTCManager shareRtc] joinChannelWithToken:rtcToken
                                                   roomID:self.roomModel.roomID
                                                   userID:[LocalUserComponent userModel].uid
                                                   isHost:[self isHost]];
    }

    self.staticView.roomModel = self.roomModel;

    [ChorusDataManager shared].currentSongModel = songModel;
    [ChorusDataManager shared].leadSingerUserModel = leadSingerUserModel;
    [ChorusDataManager shared].succentorUserModel = succentorUserModel;
    [self.bottomView updateBottomLists];
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.staticView];
    [self.staticView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
    alertModel.title = LocalizedString(@"button_close_live");
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"button_close_live")]) {
            [wself hangUp:YES];
        }
    };
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"chorus_button_cancel");
    NSString *message = LocalizedString(@"label_alert_title");
    [[AlertActionManager shareAlertActionManager] showWithMessage:message actions:@[ alertCancelModel, alertModel ]];
}

- (void)navigationControllerPop {
    UIViewController *jumpVC = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"ChorusRoomListsViewController"]) {
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

- (void)showPickSongView {
    [self.pickSongComponent show];
}

- (void)updateIMModel:(BaseIMModel *)imModel {
    if ([imModel.userID isEqualToString:self.roomModel.hostUid]) {
        imModel.iconImage = [UIImage imageNamed:@"im_host" bundleName:HomeBundleName];
    }
}

#pragma mark - Getter

- (ChorusTextInputComponent *)textInputComponent {
    if (!_textInputComponent) {
        _textInputComponent = [[ChorusTextInputComponent alloc] init];
    }
    return _textInputComponent;
}

- (ChorusStaticView *)staticView {
    if (!_staticView) {
        _staticView = [[ChorusStaticView alloc] init];
        __weak typeof(self) weakSelf = self;
        _staticView.closeButtonDidClickBlock = ^{
            if ([weakSelf isHost]) {
                [weakSelf showEndView];
            } else {
                [weakSelf hangUp:YES];
            }
        };
    }
    return _staticView;
}

- (ChorusRoomBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ChorusRoomBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (BaseIMComponent *)imComponent {
    if (!_imComponent) {
        _imComponent = [[BaseIMComponent alloc] initWithSuperView:self.view];
        [_imComponent remakeTopConstraintValue:496];
    }
    return _imComponent;
}

- (ChorusMusicComponent *)musicComponent {
    if (!_musicComponent) {
        _musicComponent = [[ChorusMusicComponent alloc] initWithSuperView:self.view];
        _musicComponent.delegate = self;
    }
    return _musicComponent;
}

- (void)dealloc {
    [self.musicComponent dismissTuningPanel];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[AlertActionManager shareAlertActionManager] dismiss:nil];
    [ChorusDataManager destroyDataManager];
}

- (ChorusPickSongComponent *)pickSongComponent {
    if (!_pickSongComponent) {
        _pickSongComponent = [[ChorusPickSongComponent alloc] initWithSuperView:self.view roomID:self.roomModel.roomID];
        _pickSongComponent.delegate = self;
    }
    return _pickSongComponent;
}

@end
