// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsComponent.h"
#import "LiveAddGuestsApplyView.h"
#import "LiveAddGuestsPendingView.h"
#import "LiveAddGuestsRoomView.h"
#import "LiveRTCManager.h"
#import "LiveSettingVideoConfig.h"
#import "NetworkingTool.h"
#import "LiveAddGuestsContentView.h"
#import "LiveRtcLinkSession.h"

NSTimeInterval const LiveApplyOvertimeInterval = 4.0;

@interface LiveAddGuestsComponent () <LiveAddGuestsRoomViewDelegate, LiveAddGuestsDelegate>

@property (nonatomic, weak) LiveAddGuestsContentView *listsView;
@property (nonatomic, weak) LiveAddGuestsApplyView *applyView;
@property (nonatomic, weak) LiveAddGuestsPendingView *pendingView;
@property (nonatomic, weak) LiveAddGuestsRoomView *liveAddGuestsRoomView;

@property (nonatomic, copy) void (^dismissBlock)(LiveAddGuestsDismissState state);
@property (nonatomic, copy) LiveRoomInfoModel *roomInfoModel;
@property (nonatomic, copy) NSString *hostUid;
@property (nonatomic, copy) NSArray<LiveUserModel *> *userList;
@property (nonatomic, strong) LiveUserModel *sheetUserModel;
@property (nonatomic, strong) NSMutableDictionary *linkerDic;
@property (nonatomic, assign) CFAbsoluteTime applyTime;
@property (nonatomic, strong) NSDate *fisrtGuestLicMicTime;
@property (nonatomic, assign) BOOL isUnread;

@end

@implementation LiveAddGuestsComponent

- (instancetype)initWithRoomID:(LiveRoomInfoModel *)roomInfoModel {
    self = [super init];
    if (self) {
        _roomInfoModel = roomInfoModel;
    }
    return self;
}

- (void)bindLinkerId:(NSString *)linkerId uid:(NSString *)uid {
    if (NOEmptyStr(linkerId) && NOEmptyStr(uid)) {
        [self.linkerDic setValue:linkerId forKey:uid];
    }
}

- (NSString *)getLinkerIdWithUid:(NSString *)uid {
    if (NOEmptyStr(uid)) {
        return self.linkerDic[uid];
    } else {
        return @"";
    }
}

- (void)updateFirstGuestLinkMicTime:(NSDate *)time {
    self.fisrtGuestLicMicTime = time;
    if(self.listsView) {
        [self.listsView updateCoHostStartTime:self.fisrtGuestLicMicTime];
    }
}

#pragma mark - Publish List
- (void)showListWithSwitch:(BOOL)isSwitch
                     block:(void (^)(LiveAddGuestsDismissState state))dismissBlock {
    if(self.listsView) {
        return;
    }
    self.dismissBlock = dismissBlock;
    UIViewController *rootVC = [DeviceInforTool topViewController];
    LiveAddGuestsContentView *listsView = [[LiveAddGuestsContentView alloc] init];
    listsView.delegate = self;
    listsView.backgroundColor = [UIColor clearColor];
    [rootVC.view addSubview:listsView];
    [listsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(rootVC.view);
        make.top.equalTo(rootVC.view).offset(SCREEN_HEIGHT);
    }];
    _listsView = listsView;
    __weak __typeof(self) wself = self;
    listsView.clickMaskBlcok = ^{
        [wself dismissList];
    };
    listsView.requestRefreshBlcok = ^{
        [wself loadDataWithGetAudienceList];
    };
    [listsView.superview layoutIfNeeded];
    [listsView.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [listsView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rootVC.view).offset(0);
        }];
        [listsView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (isSwitch) {
                [listsView switchApplicationList];
            }
        }
    }];
    [self.listsView updateCoHostStartTime:self.fisrtGuestLicMicTime];
    [self loadDataWithGetAudienceList];
}
- (void)dismissList {
    [self dismissUserListView:LiveAddGuestsDismissStateNone];
}
- (void)updateList {
    if (self.listsView) {
        [self loadDataWithGetAudienceList];
    }
}
- (void) updateApplicationList {
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveGetAudienceList:self.roomInfoModel.roomID
                                  block:^(NSArray<LiveUserModel *> *userList,
                                          RTSACKModel *_Nonnull model) {
        if (model.result) {
            NSArray *list = [wself getUserListWithType:1 userList:userList];
            wself.listsView.applicationDataLists = [list copy];
            if(list.count <= 0 ) {
                [wself updateListUnread:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReadApplyMessage object:nil];
            }
        }
    }];
}
- (void)updateListUnread:(BOOL)isUnread {
    _isUnread = isUnread;
    self.listsView.isUnread = isUnread;
}


#pragma mark - Publish Live Room
- (void)showAddGuests:(UIView *)superView
              hostUid:(NSString *)hostUid
             userList:(NSArray<LiveUserModel *> *)userList {
    _isConnect = YES;
    _hostUid = hostUid;
    _userList = userList;
    
    if (![hostUid isEqualToString:[LocalUserComponent userModel].uid]) {
        [self loadDataWithupdateRes:YES];
        [self updateLiveInteractStatus:LiveInteractStatusAudienceLink];
    }
    
    // Update UI
    if (!_liveAddGuestsRoomView) {
        LiveAddGuestsRoomView *liveAddGuestsRoomView = [[LiveAddGuestsRoomView alloc] initWithHostID:hostUid roomInfoModel:self.roomInfoModel];
        liveAddGuestsRoomView.delegate = self;
        [superView addSubview:liveAddGuestsRoomView];
        [liveAddGuestsRoomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
        _liveAddGuestsRoomView = liveAddGuestsRoomView;
    }
    [_liveAddGuestsRoomView updateGuests:userList];
    
    __weak __typeof(self) wself = self;
    [[LiveRTCManager shareRtc] didChangeNetworkQuality:^(LiveNetworkQualityStatus status, NSString *_Nonnull uid) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
            [wself.liveAddGuestsRoomView updateNetworkQuality:status uid:uid];
        }));
    }];
}
- (NSString *)removeAddGuestsUid:(NSString *)uid
                        userList:(NSArray<LiveUserModel *> *)userList {
    LiveUserModel *deleteUserModel = nil;
    if (_liveAddGuestsRoomView && _userList.count > 0) {
        NSArray *list = [_userList copy];
        for (LiveUserModel *userModel in list) {
            if ([userModel.uid isEqualToString:uid]) {
                deleteUserModel = userModel;
                break;
            }
        }
        _userList = [userList copy];
        if (_userList.count > 0) {
            // When the current make Guests user is greater than 0, only update the make Guests list
            // If the connected microphone user is less than or equal to 0, it will automatically receive the end connection callback -closeAddGuests
            [_liveAddGuestsRoomView updateGuests:_userList];
        }
    }
    return deleteUserModel.name;
}
- (void)closeAddGuests {
    _isConnect = NO;

    if (![_hostUid isEqualToString:[LocalUserComponent userModel].uid]) {
        // Audience
//        [[LiveRTCManager shareRtc] switchVideoCapture:NO];
//        [[LiveRTCManager shareRtc] switchAudioCapture:NO];
        // Update the guest's own resolution
        [self loadDataWithupdateRes:NO];
        [self updateLiveInteractStatus:LiveInteractStatusOther];
    }
    
    if (_liveAddGuestsRoomView) {
        [_liveAddGuestsRoomView removeAllSubviews];
        [_liveAddGuestsRoomView removeFromSuperview];
        _liveAddGuestsRoomView = nil;
    }
}

- (void)updateGuests:(NSArray<LiveUserModel *> *)userList {
    _userList = userList;
    if (self.liveAddGuestsRoomView) {
        [self.liveAddGuestsRoomView updateGuests:userList];
    }
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    if (self.liveAddGuestsRoomView) {
        [self.liveAddGuestsRoomView updateGuestsMic:mic uid:uid];
    }
    if (self.listsView) {
        [self.listsView updateGuestsMic:mic uid:uid];
    }
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    if (self.liveAddGuestsRoomView) {
        [self.liveAddGuestsRoomView updateGuestsCamera:camera uid:uid];
    }
    if (self.listsView) {
        [self.listsView updateGuestsCamera:camera uid:uid];
    }
}

#pragma mark - Publish Apply
- (void)showApply:(LiveUserModel *)loginUserModel hostID:(NSString *)hostID {
    if (loginUserModel.status == LiveInteractStatusApplying
        && CFAbsoluteTimeGetCurrent() - self.applyTime > LiveApplyOvertimeInterval) {
        loginUserModel.status = LiveInteractStatusOther;
    }
    UIViewController *rootVC = [DeviceInforTool topViewController];
    LiveAddGuestsApplyView *applyView = [[LiveAddGuestsApplyView alloc] init];
    applyView.userModel = loginUserModel;
    applyView.backgroundColor = [UIColor clearColor];
    [rootVC.view addSubview:applyView];
    [applyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(rootVC.view);
    }];
    _applyView = applyView;
    __weak __typeof(self) wself = self;
    applyView.clickApplyBlock = ^{
        [wself loadDataWithApply];
    };
    applyView.clickCancelBlock = ^{
        [wself closeApply];
    };
    [applyView.superview layoutIfNeeded];
    [applyView.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [applyView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rootVC.view).offset(0);
        }];
        [applyView.superview layoutIfNeeded];
    }];
}
- (void)closeApply {
    if (_applyView && _applyView.superview) {
        [_applyView removeFromSuperview];
        _applyView = nil;
    }
}
- (BOOL)IsDisplayApplyList {
    return [self.listsView IsDisplayApplyList];;
}

#pragma mark - Publish Pending
- (void)showPending {
    UIViewController *rootVC = [DeviceInforTool topViewController];
    LiveAddGuestsPendingView *pendingView = [[LiveAddGuestsPendingView alloc] init];
    pendingView.backgroundColor = [UIColor clearColor];
    [rootVC.view addSubview:pendingView];
    [pendingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(rootVC.view);
    }];
    _pendingView = pendingView;
    __weak __typeof(self) wself = self;
    pendingView.clickCancelBlock = ^(BOOL isCancel) {
        if (isCancel) {
            [wself cancelApplyRequestIfNeed:YES];
        } else {
            [wself closePending];
        }
    };
    [pendingView.superview layoutIfNeeded];
    [pendingView.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [pendingView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rootVC.view).offset(0);
        }];
        [pendingView.superview layoutIfNeeded];
    }];
}
- (void)closePending {
    if (self.pendingView.superview) {
        [self.pendingView removeFromSuperview];
        self.pendingView = nil;
    }
}

#pragma mark - Network request Method

- (void)loadDataWithGetAudienceList {
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveGetAudienceList:self.roomInfoModel.roomID
                                  block:^(NSArray<LiveUserModel *> *userList,
                                          RTSACKModel *_Nonnull model) {
        if (model.result) {
            wself.listsView.onlineDataLists = [wself getUserListWithType:0 userList:userList];
            wself.listsView.applicationDataLists = [wself getUserListWithType:1 userList:userList];
//            [wself.listsView updateCoHostStartTime:wself.fisrtGuestLicMicTime];
        }
    }];
}
- (void)loadDataWithUpdateMediaStatus:(LiveUserModel *)userModel
                                  mic:(NSInteger)mic
                               camera:(NSInteger)camera {
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveManageGuestMedia:self.roomInfoModel.roomID
                             guestRoomID:userModel.roomID
                             guestUserID:userModel.uid
                                     mic:mic
                                  camera:camera
                                   block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}
- (void)loadDataWithAudienceLinkmicKick:(LiveUserModel *)userModel {
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveAudienceLinkmicKick:self.roomInfoModel.roomID
                             audienceRoomID:userModel.roomID
                             audienceUserID:userModel.uid
                                      block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        } else {
            [wself.liveAddGuestsRoomView removeGuests:userModel.uid];
        }
    }];
}
- (void)loadDataWithAudienceLinkmicFinish {
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAudienceLinkmicFinish:self.roomInfoModel.roomID
                                        block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"end_allGuesst")];
        }
    }];
}
- (void)loadDataWithupdateRes:(BOOL)isOnMic {
    CGSize videoSize = isOnMic ? [LiveSettingVideoConfig defultVideoConfig].guestVideoSize : CGSizeZero;
    [LiveRTSManager liveUpdateResWithSize:videoSize
                                          roomID:self.roomInfoModel.roomID
                                           block:^(RTSACKModel * _Nonnull model) {
        if (model.result) {
            [[LiveRTCManager shareRtc] updateVideoEncoderResolution:videoSize];
        }
    }];
}
- (void)loadDataWithApply {
    [self closeApply];
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAudienceLinkmicApply:self.roomInfoModel.roomID
                                       block:^(NSString *linkerID,
                                               RTSACKModel *model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (model.result ||
            model.code == RTSStatusCodeUserIsInviting ||
            model.code == RTSStatusCodeUserIsNewInviting) {
            // Initiate an invitation
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"request_sent_waiting")];
            wself.applyTime = CFAbsoluteTimeGetCurrent();
            [wself showPending];
            [wself updateLiveInteractStatus:LiveInteractStatusApplying];
            [wself bindLinkerId:linkerID uid:[LocalUserComponent userModel].uid];
        } else if (model.code == RTSStatusCodeHostLinkOtherHost)  {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"host_is_in_pk")];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}
- (void)cancelApplyRequestIfNeed:(BOOL)showLoading {
    NSString *linkerID = self.linkerDic[[LocalUserComponent userModel].uid];
    if (!linkerID) {
        return;
    }
    if (showLoading) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showLoading];
    }
    WeakSelf;
    [LiveRTSManager liveAudienceCancelApplyLinkerId:linkerID
                                              block:^(RTSACKModel * _Nonnull model) {
        StrongSelf;
        if (showLoading) {
            [[ToastComponent shareToastComponent] dismiss];
            NSString *message = model.result ? LocalizedString(@"application_cancel") : model.message;
            [[ToastComponent shareToastComponent] showWithMessage:message];
        }
        if (model.result) {
            // Initiate an invitation
            [sself closePending];
            [sself updateLiveInteractStatus:LiveInteractStatusOther];
        } else if(model.code == 560){
            [sself closePending];
            [sself updateLiveInteractStatus:LiveInteractStatusOther];
        }
    }];
}
- (void)loadDataWithPermitAudienceLinkmic:(NSString *)audienceRoomID
                           audienceUserID:(NSString *)audienceUserID
                                    reply:(LiveInviteReply)reply
                                    block:(void (^)(NSString *rtcRoomID,
                                                    NSString *rtcToken,
                                                    NSArray<LiveUserModel *> *userList))block {
    NSString *linkerID = self.linkerDic[audienceUserID];
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAudienceLinkmicPermit:self.roomInfoModel.roomID
                               audienceRoomID:audienceRoomID
                               audienceUserID:audienceUserID
                                     linkerID:linkerID
                                   permitType:reply
                                        block:^(NSString *rtcRoomID,
                                                NSString *rtcToken,
                                                NSArray<LiveUserModel *> *userList,
                                                RTSACKModel *model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (model.result) {
            if (block) {
                block(rtcRoomID, rtcToken, userList);
            }
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
    }];
}

#pragma mark - LiveAddGuestsListDelegate
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
          clickReject:(LiveUserModel *)model {
    __weak __typeof(self) wself = self;
    [self loadDataWithPermitAudienceLinkmic:model.roomID
                             audienceUserID:model.uid
                                      reply:LiveInviteReplyForbade
                                      block:^(NSString *rtcRoomID,
                                              NSString *rtcToken,
                                              NSArray<LiveUserModel *> *userList) {
        [wself updateList];
    }];
}
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
           clickAgree:(LiveUserModel *)model {
    __weak __typeof(self) wself = self;
    [self.delegate guestsComponent:self clickAgree:model];
    
    [self loadDataWithPermitAudienceLinkmic:model.roomID
                             audienceUserID:model.uid
                                      reply:LiveInviteReplyPermitted
                                      block:^(NSString *rtcRoomID,
                                              NSString *rtcToken,
                                              NSArray<LiveUserModel *> *userList) {
        if(userList.count < 2) {
            [[ToastComponent shareToastComponent] showWithMessage:@"record not found"];
        }
        [wself updateList];
    }];
}
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
            clickKick:(nonnull LiveUserModel *)model {
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"cancel");
    
    AlertActionModel *alertConfirmModel = [[AlertActionModel alloc] init];
    alertConfirmModel.title = LocalizedString(@"confirm");
    __weak typeof(self) weakSelf = self;
    alertConfirmModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        [weakSelf loadDataWithAudienceLinkmicKick:model];
    };
    
    AlertUserModel *alertUserModel = [[AlertUserModel alloc] init];
    alertUserModel.avatarImage = [UIImage imageNamed:model.avatarName bundleName:HomeBundleName subBundleName:AvatarBundleName];
    alertUserModel.userName = model.name;
    NSString *title = LocalizedString(@"kickoff_guest");
    NSString *message = LocalizedString(@"kickoff_guest_tip");
    
    [[AlertActionManager shareAlertActionManager] showWithTitle:title
                                                        message:message
                                                        actions:@[alertCancelModel, alertConfirmModel]
                                                 alertUserModel:alertUserModel];
    
}
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
             clickMic:(LiveUserModel *)model {
    [self loadDataWithUpdateMediaStatus:model
                                    mic:0
                                 camera:-1];
}
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
          clickCamera:(LiveUserModel *)model {
    [self loadDataWithUpdateMediaStatus:model
                                    mic:-1
                                 camera:0];
}
- (void)liveAddGuests:(LiveAddGuestsContentView *)liveAddGuests
    clickCloseConnect:(BOOL)isEnd {
    [self loadDataWithAudienceLinkmicFinish];
}

#pragma mark - LiveAddGuestsRoomViewDelegate
- (void)guestsRoomView:(LiveAddGuestsRoomView *)guestsRoomView
       clickMoreButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(guestsComponent:clickMoreButton:)]) {
        [self.delegate guestsComponent:self clickMoreButton:model];
    }
}
- (void)guestsRoomView:(LiveAddGuestsRoomView *)guestsRoomView
        clickMultiUser:(LiveUserModel *)model {
    if ([self.hostUid isEqualToString:[LocalUserComponent userModel].uid]) {
        if(!model.uid) {
            if(!self.listsView) {
                [self showListWithSwitch:self.isUnread block:^(LiveAddGuestsDismissState state) {
                    
                }];
            }
        }
    } else {
        if ([guestsRoomView getIsGuests:[LocalUserComponent userModel].uid]) {
        } else {
//            [self showApply:model hostID:self.hostUid];
        }
    }
}

#pragma mark - LivePKListsViewDelegate
- (void)LiveAddGuestsOnlineListsView:(LiveAddGuestsOnlineListsView *)LiveAddGuestsOnlineListsView
                   clickButton:(LiveUserModel *)model {
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveAudienceLinkmicInvite:self.roomInfoModel.roomID
                               audienceRoomID:model.roomID
                               audienceUserID:model.uid
                                        extra:@""
                                        block:^(NSString * _Nullable linkerID,
                                                RTSACKModel * ackModel) {
        if (ackModel.result ||
            ackModel.code == RTSStatusCodeUserIsInviting ||
            ackModel.code == RTSStatusCodeUserIsNewInviting) {
            [wself dismissUserListView:LiveAddGuestsDismissStateInvite];
            NSString *message = [NSString stringWithFormat:LocalizedString(@"%@ waiting_response."), model.name];
            [[ToastComponent shareToastComponent] showWithMessage:message];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:ackModel.message];
        }
    }];
}

#pragma mark - Private Action
- (NSArray *)getUserListWithType:(NSInteger)type
                        userList:(NSArray *)userList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < userList.count; i++) {
        LiveUserModel *userModel = userList[i];
        LiveInteractStatus status = LiveInteractStatusOther;
        if (type == 0) {
            status = LiveInteractStatusAudienceLink;
        } else if (type == 1) {
            status = LiveInteractStatusApplying;
        } else {
            status = LiveInteractStatusOther;
        }
        if (userModel.status == status) {
            [list addObject:userModel];
        }
    }
    return [list copy];
}

- (void)closeConnectAction {
    [self dismissUserListView:LiveAddGuestsDismissStateCloseConnect];
}
- (void)dismissUserListView:(LiveAddGuestsDismissState)state {
    if (self.listsView) {
        [self.listsView removeFromSuperview];
        self.listsView = nil;
    }
    
    if (self.dismissBlock) {
        self.dismissBlock(state);
    }
}
- (LiveUserModel *)getOwnerUserModel:(NSArray<LiveUserModel *> *)userModelList {
    LiveUserModel *model = nil;
    for (LiveUserModel *tempUserModel in userModelList) {
        if ([tempUserModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
            model = tempUserModel;
            break;
        }
    }
    return model;
}
- (void)updateLiveInteractStatus:(LiveInteractStatus)status {
    if ([self.delegate respondsToSelector:@selector(guestsComponent:updateUserStatus:)]) {
        [self.delegate guestsComponent:self updateUserStatus:status];
    }
}

#pragma mark - Getter

- (NSMutableDictionary *)linkerDic {
    if (!_linkerDic) {
        _linkerDic = [[NSMutableDictionary alloc] init];
    }
    return _linkerDic;
}


@end
