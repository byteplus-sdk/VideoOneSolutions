// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCoHostComponent.h"
#import "LiveCoHostRoomView.h"
#import "LiveDuringPKView.h"
#import "LiveInvitePKView.h"
#import "LivePKContentView.h"
#import "LiveRTCManager.h"
#import "LiveSettingVideoConfig.h"

@interface LiveCoHostComponent () <LivePKContentViewDelegate>

@property (nonatomic, weak) LiveInvitePKView *invitePKView;
@property (nonatomic, weak) LiveDuringPKView *duringPKView;
@property (nonatomic, weak) LiveCoHostRoomView *liveCoHostRoomView;
@property (nonatomic, strong) LivePKContentView *contentView;

@property (nonatomic, copy) void (^dismissBlock)(LiveCoHostDismissState state);
@property (nonatomic, copy) LiveRoomInfoModel *roomInfoModel;
@property (nonatomic, copy) NSArray<LiveUserModel *> *userModelList;
@property (nonatomic, strong) NSMutableDictionary *linkerDic;
@property (nonatomic, strong) NSMutableArray *inviterList;
@property (nonatomic, assign) BOOL isSendInvicationOk;

@end

@implementation LiveCoHostComponent

- (instancetype)initWithRoomID:(LiveRoomInfoModel *)roomInfoModel {
    self = [super init];
    if (self) {
        _roomInfoModel = roomInfoModel;
        _isSendInvicationOk = YES;
    }
    return self;
}

- (void)bindLinkerId:(NSString *)linkerId uid:(NSString *)uid {
    if (NOEmptyStr(linkerId) && NOEmptyStr(uid)) {
        [self.linkerDic setValue:linkerId forKey:uid];
    }
}

#pragma mark - Publish List Action
- (void)showInviteList:(void (^)(LiveCoHostDismissState state))dismissBlock {
    self.dismissBlock = dismissBlock;
    UIViewController *rootVC = [DeviceInforTool topViewController];

    [rootVC.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(rootVC.view);
        make.top.equalTo(rootVC.view).offset(SCREEN_HEIGHT);
    }];

    // Start animation
    [self.contentView.superview setNeedsLayout];
    [self.contentView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.top.equalTo(rootVC.view).offset(0);
                         }];
                         [self.contentView.superview layoutIfNeeded];
                     }];

    [self loadDataWithRaiseHandLists];
}
- (void)dismissInviteList {
    [self maskButtonAction];
}

- (void)updateInviteList {
    [self loadDataWithRaiseHandLists];
}

#pragma mark - Publish During Action
- (void)showDuringPK {
    UIViewController *rootVC = [DeviceInforTool topViewController];

    LiveDuringPKView *duringPKView = [[LiveDuringPKView alloc] initWithUserList:self.userModelList];
    duringPKView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDuringPK)];
    [duringPKView addGestureRecognizer:tap];
    [rootVC.view addSubview:duringPKView];
    [duringPKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(rootVC.view);
        make.top.equalTo(rootVC.view).offset(SCREEN_HEIGHT);
    }];

    // Start animation
    [duringPKView.superview setNeedsLayout];
    [duringPKView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [duringPKView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.top.equalTo(rootVC.view).offset(0);
                         }];
                         [duringPKView.superview layoutIfNeeded];
                     }];

    __weak __typeof(self) wself = self;
    duringPKView.clickEndBlock = ^{
        [wself loadDataWithAnchorLinkmicFinish];
    };

    self.duringPKView = duringPKView;
}
- (void)closeDuringPK {
    if (self.duringPKView.superview) {
        [self.duringPKView removeFromSuperview];
        self.duringPKView = nil;
    }
}

#pragma mark - Invite PK
- (void)pushToInviteList:(LiveUserModel *)fromUserModel {
    [self.inviterList addObject:fromUserModel];
    if (self.inviterList.count == 1) {
        [self showInvitePK:fromUserModel];
    } else {
        if (self.invitePKView && self.invitePKView.superview) {
            [self loadDataWithAnchorLinkmicReply:self.inviterList[0]
                                       replyType:LiveInviteReplyForbade
                                   completeBlock:^(BOOL result){}];
            [self showInvitePK:fromUserModel];
        }
    }
}
- (void)showInvitePK:(LiveUserModel *)fromUserModel {
    UIViewController *rootVC = [DeviceInforTool topViewController];
    if (!self.invitePKView) {
        LiveInvitePKView *invitePKView = [[LiveInvitePKView alloc] init];
        [invitePKView dismissDelayAfterTenSeconds];
        invitePKView.backgroundColor = [UIColor clearColor];
        [rootVC.view addSubview:invitePKView];
        [invitePKView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(rootVC.view);
        }];
        self.invitePKView = invitePKView;
    }
    self.invitePKView.fromUserModel = fromUserModel;
    self.invitePKView.alpha = 0;

    [UIView animateWithDuration:0.15 animations:^{
        self.invitePKView.alpha = 1;
    }];

    __weak __typeof(self) wself = self;
    self.invitePKView.clickAgreeBlcok = ^{
        [wself loadDataWithAnchorLinkmicReply:fromUserModel
                                    replyType:LiveInviteReplyPermitted
                                completeBlock:^(BOOL result) {
                                    if (result) {
                                        wself.linkerID = [wself.linkerDic objectForKey:fromUserModel.uid];
                                    }
                                }];
    };
    self.invitePKView.clickRejectBlcok = ^{
        [wself loadDataWithAnchorLinkmicReply:fromUserModel
                                    replyType:LiveInviteReplyForbade
                                completeBlock:^(BOOL result){}];
    };
}

- (void)dismissInvitePKView {
    if (self.invitePKView && self.invitePKView.superview) {
        [self.inviterList removeObjectAtIndex:0];
        [self.invitePKView removeFromSuperview];
        self.invitePKView = nil;
    }
}

#pragma mark - Publish Room Action

- (void)startCoHostBattleWithUsers:(NSArray<LiveUserModel *> *)userModelList {
    _isConnect = YES;
    self.userModelList = userModelList.copy;
    __weak __typeof(self) wself = self;
    // Enable network monitoring
    [[LiveRTCManager shareRtc] didChangeNetworkQuality:^(LiveNetworkQualityStatus status, NSString *_Nonnull uid) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), (^{
                                      [wself.liveCoHostRoomView updateNetworkQuality:status uid:uid];
                                  }));
    }];
}
- (void)updateCoHostRoomView:(UIView *)superView
               userModelList:(NSArray<LiveUserModel *> *)userModelList
              loginUserModel:(LiveUserModel *)loginUserModel {
    // UI
    CGFloat coHostWidth = SCREEN_WIDTH;
    CGFloat coHostHeight = ceilf((SCREEN_WIDTH / 2) * 16 / 9);
    LiveCoHostRoomView *liveCoHostRoomView = [[LiveCoHostRoomView alloc] initWithRenderSize:CGSizeMake(coHostWidth, coHostHeight) roomInfoModel:self.roomInfoModel];
    [superView addSubview:liveCoHostRoomView];
    [liveCoHostRoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    [liveCoHostRoomView updateGuestsMic:loginUserModel.mic
                                    uid:loginUserModel.uid];
    [liveCoHostRoomView updateGuestsCamera:loginUserModel.camera
                                       uid:loginUserModel.uid];
    [liveCoHostRoomView startTime];
    liveCoHostRoomView.userModelList = userModelList;

    self.liveCoHostRoomView = liveCoHostRoomView;
}
- (void)closeCoHost {
    _isConnect = NO;

    if (self.liveCoHostRoomView) {
        [self.liveCoHostRoomView removeFromSuperview];
        self.liveCoHostRoomView = nil;
    }
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    [self.liveCoHostRoomView updateGuestsMic:mic uid:uid];
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    [self.liveCoHostRoomView updateGuestsCamera:camera uid:uid];
}

#pragma mark - Load Data
- (void)loadDataWithAnchorLinkmicReply:(LiveUserModel *)inviter
                             replyType:(LiveInviteReply)replyType
                         completeBlock:(void (^)(BOOL result))completeBlock {
    [self dismissInvitePKView];
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveAnchorLinkmicReply:self.roomInfoModel.roomID
                             inviterRoomID:inviter.roomID
                             inviterUserID:inviter.uid
                                  linkerID:[self.linkerDic objectForKey:inviter.uid]
                                 replyType:replyType
                                     block:^(NSString *_Nullable rtcRoomID, NSString *_Nullable rtcToken, NSArray<LiveUserModel *> *_Nullable userList, RTSACKModel *_Nonnull model) {
                                         [[ToastComponent shareToastComponent] dismiss];
                                         if (!model.result) {
                                             [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                         } else {
                                             if (replyType == LiveInviteReplyPermitted) {
                                                 if ([wself.delegate respondsToSelector:@selector(coHostComponent:invitePermitted:rtcRoomID:rtcToken:)]) {
                                                     [wself.delegate coHostComponent:wself invitePermitted:userList rtcRoomID:rtcRoomID rtcToken:rtcToken];
                                                 }
                                             } else {
                                                 if ([wself.delegate respondsToSelector:@selector(coHostComponent:inviteRejected:rtcRoomID:rtcToken:)]) {
                                                     [wself.delegate coHostComponent:wself inviteRejected:userList rtcRoomID:rtcRoomID rtcToken:rtcToken];
                                                 }
                                             }
                                         }
                                         if (completeBlock) {
                                             completeBlock(model.result);
                                         }
                                     }];
}
- (void)loadDataWithRaiseHandLists {
    __weak __typeof(self) wself = self;
    [LiveRTSManager liveGetActiveAnchorList:self.roomInfoModel.roomID
                                      block:^(NSArray<LiveUserModel *> *_Nullable userList, RTSACKModel *_Nonnull model) {
                                          if (model.result) {
                                              wself.contentView.dataLists = userList;
                                          }
                                      }];
}
- (void)loadDataWithAnchorLinkmicFinish {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAnchorLinkmicFinish:self.linkerID
                                      block:^(RTSACKModel *_Nonnull model) {
                                          [[ToastComponent shareToastComponent] dismiss];
                                          if (!model.result) {
                                              if (model.code == 560) {
                                                  if ([wself.delegate respondsToSelector:@selector(coHostComponent:dealExceptionalCase:)]) {
                                                      [wself.delegate coHostComponent:wself dealExceptionalCase:model];
                                                  }
                                              }
                                          } else {
                                              [wself closeDuringPK];
                                          }
                                      }];
}

#pragma mark - LivePKContentViewDelegate
- (void)livePKContentView:(LivePKContentView *)livePKContentView
              clickButton:(LiveUserModel *)userModel {
    [self dismissUserListView:LiveCoHostDismissStateInviteIng];
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveAnchorLinkmicInvite:self.roomInfoModel.roomID
                              inviteeRoomID:userModel.roomID
                              inviteeUserID:userModel.uid
                                      extra:@""
                                      block:^(NSString *linkerID,
                                              RTSACKModel *model) {
                                          [[ToastComponent shareToastComponent] dismiss];
                                          if (model.result) {
                                              // Initiate an invitation
                                              [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"waiting_response")];
                                              if ([self.delegate respondsToSelector:@selector(coHostComponent:haveSentPKRequestTo:)]) {
                                                  [self.delegate coHostComponent:self haveSentPKRequestTo:userModel];
                                              }
                                          } else {
                                              [[ToastComponent shareToastComponent] showWithMessage:model.message];
                                          }
                                      }];
}

#pragma mark - Private Action

- (void)maskButtonAction {
    [self dismissUserListView:LiveCoHostDismissStateNone];
}

- (void)dismissUserListView:(LiveCoHostDismissState)state {
    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }

    if (self.dismissBlock) {
        self.dismissBlock(state);
    }
}

- (LiveUserModel *)getOtherUserModel:(NSArray<LiveUserModel *> *)userModelList {
    LiveUserModel *otherModel = nil;
    for (LiveUserModel *tempUserModel in userModelList) {
        if (![tempUserModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
            otherModel = tempUserModel;
            break;
        }
    }
    return otherModel;
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

#pragma mark - Getter

- (LivePKContentView *)contentView {
    if (!_contentView) {
        _contentView = [[LivePKContentView alloc] init];
        _contentView.delegate = self;
        _contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskButtonAction)];
        [_contentView addGestureRecognizer:tap];
    }
    return _contentView;
}

- (NSMutableDictionary *)linkerDic {
    if (!_linkerDic) {
        _linkerDic = [[NSMutableDictionary alloc] init];
    }
    return _linkerDic;
}

- (NSMutableArray *)inviterList {
    if (!_inviterList) {
        _inviterList = [[NSMutableArray alloc] init];
    }
    return _inviterList;
}

@end
