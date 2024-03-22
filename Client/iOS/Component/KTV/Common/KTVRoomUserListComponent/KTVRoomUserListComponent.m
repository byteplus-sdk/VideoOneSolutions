//
//  KTVRoomUserListComponent.m
//  veRTC_Demo
//
//  Created by on 2021/5/19.
//  
//

#import "KTVRoomUserListComponent.h"
#import "KTVRoomTopSelectView.h"
#import "KTVRoomTopSeatView.h"
#import "KTVRTSManager.h"

@interface KTVRoomUserListComponent () <KTVRoomTopSelectViewDelegate, KTVRoomRaiseHandListsViewDelegate, KTVRoomAudienceListsViewDelegate>

@property (nonatomic, strong) KTVRoomTopSeatView *topSeatView;
@property (nonatomic, strong) KTVRoomTopSelectView *topSelectView;
@property (nonatomic, strong) KTVRoomRaiseHandListsView *applyListsView;
@property (nonatomic, strong) KTVRoomAudienceListsView *onlineListsView;
@property (nonatomic, strong) UIButton *maskButton;

@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, strong) KTVRoomModel *roomModel;
@property (nonatomic, copy) NSString *seatID;
@property (nonatomic, assign) BOOL isRed;

@end


@implementation KTVRoomUserListComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        _isRed = NO;
    }
    return self;
}

#pragma mark - Publish Action

- (void)showRoomModel:(KTVRoomModel *)roomModel
               seatID:(NSString *)seatID
         dismissBlock:(void (^)(void))dismissBlock {
    _roomModel = roomModel;
    _seatID = seatID;
    self.dismissBlock = dismissBlock;
    UIViewController *rootVC = [DeviceInforTool topViewController];
    
    [rootVC.view addSubview:self.maskButton];
    [self.maskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.height.equalTo(rootVC.view);
        make.top.equalTo(rootVC.view).offset(SCREEN_HEIGHT);
    }];
    
    [self.maskButton addSubview:self.applyListsView];
    [self.applyListsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_offset(364 + [DeviceInforTool getVirtualHomeHeight]);
        make.bottom.mas_offset(0);
    }];
    
    [self.maskButton addSubview:self.onlineListsView];
    [self.onlineListsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.applyListsView);
    }];
    
    [self.maskButton addSubview:self.topSelectView];
    [self.topSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.maskButton);
        make.bottom.equalTo(self.applyListsView.mas_top);
        make.height.mas_equalTo(44);
    }];
    
    [self.topSelectView addSubview:self.topSeatView];
    [self.topSeatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topSelectView).offset(-16);
        make.height.top.equalTo(self.topSelectView);
    }];
    
    // Start animation
    [rootVC.view layoutIfNeeded];
    [self.maskButton.superview setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25
                     animations:^{
        [self.maskButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rootVC.view).offset(0);
        }];
        [self.maskButton.superview layoutIfNeeded];
    }];
    
    if (_isRed) {
        [self loadDataWithApplyLists];
        [self.topSelectView updateSelectItem:NO];
        self.onlineListsView.hidden = YES;
        self.applyListsView.hidden = NO;
    } else {
        [self loadDataWithOnlineLists];
        [self.topSelectView updateSelectItem:YES];
        self.onlineListsView.hidden = NO;
        self.applyListsView.hidden = YES;
    }
    
    __weak __typeof(self) wself = self;
    self.topSeatView.clickSwitchBlock = ^(BOOL isOn) {
        [wself loadDataWithSwitch:isOn];
    };
}

- (void)update {
    if (self.onlineListsView.superview && !self.onlineListsView.hidden) {
        [self loadDataWithOnlineLists];
    } else if (self.applyListsView.superview && !self.applyListsView.hidden) {
        [self loadDataWithApplyLists];
    } else {
        
    }
}

- (void)updateWithRed:(BOOL)isRed {
    _isRed = isRed;
    [self.topSelectView updateWithRed:isRed];
}

#pragma mark - Load Data

- (void)loadDataWithOnlineLists {
    __weak __typeof(self) wself = self;
    [KTVRTSManager getAudienceList:_roomModel.roomID
                             block:^(NSArray<KTVUserModel *> * _Nonnull userLists, RTSACKModel * _Nonnull model) {

        if (model.result) {
            wself.onlineListsView.dataLists = userLists;
        }
    }];
}

- (void)loadDataWithApplyLists {
    __weak __typeof(self) wself = self;
    [KTVRTSManager getApplyAudienceList:_roomModel.roomID
                                  block:^(NSArray<KTVUserModel *> * _Nonnull userLists, RTSACKModel * _Nonnull model) {
        if (model.result) {
            wself.applyListsView.dataLists = userLists;
        }
    }];
}

#pragma mark - KTVRoomTopSelectViewDelegate

- (void)KTVRoomTopSelectView:(KTVRoomTopSelectView *)KTVRoomTopSelectView clickCancelAction:(id)model {
    [self dismissUserListView];
}

- (void)KTVRoomTopSelectView:(KTVRoomTopSelectView *)KTVRoomTopSelectView clickSwitchItem:(BOOL)isAudience {
    if (isAudience) {
        self.onlineListsView.hidden = YES;
        self.applyListsView.hidden = NO;
        [self loadDataWithApplyLists];
    } else {
        self.onlineListsView.hidden = NO;
        self.applyListsView.hidden = YES;
        [self loadDataWithOnlineLists];
    }
}

#pragma mark - KTVRoomonlineListsViewDelegate

- (void)KTVRoomAudienceListsView:(KTVRoomRaiseHandListsView *)KTVRoomAudienceListsView clickButton:(KTVUserModel *)model {
    [self clickTableViewWithModel:model dataLists:KTVRoomAudienceListsView.dataLists];
}

#pragma mark - KTVRoomapplyListsViewDelegate

- (void)KTVRoomRaiseHandListsView:(KTVRoomRaiseHandListsView *)KTVRoomRaiseHandListsView clickButton:(KTVUserModel *)model {
    [self clickTableViewWithModel:model dataLists:KTVRoomRaiseHandListsView.dataLists];
}

#pragma mark - Private Action

- (void)loadDataWithSwitch:(BOOL)isOn {
    NSInteger type = isOn ? 1 : 2;
    [KTVRTSManager managerInteractApply:self.roomModel.roomID
                                                type:type
                                               block:^(RTSACKModel * _Nonnull model) {
  
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"operation_failed_message")];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateSeatSwitch object:@(!isOn)];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationResultSeatSwitch object:nil];
    }];
}

- (void)clickTableViewWithModel:(KTVUserModel *)userModel dataLists:(NSArray<KTVUserModel *> *)dataLists {
    if (userModel.status == KTVUserStatusDefault) {
        [KTVRTSManager inviteInteract:userModel.roomID
                                               uid:userModel.uid
                                            seatID:_seatID
                                             block:^(RTSACKModel * _Nonnull model) {
            if (!model.result) {
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            } else {
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_invitation_audience")];
                userModel.status = KTVUserStatusInvite;
            }
        }];
    } else if (userModel.status == KTVUserStatusApply) {
        __weak __typeof(self)wself = self;
        [KTVRTSManager agreeApply:userModel.roomID
                                           uid:userModel.uid
                                         block:^(RTSACKModel * _Nonnull model) {
        
            if (model.result) {
                userModel.status = KTVUserStatusApply;
                [wself updateDataLists:dataLists model:userModel];
            } else {
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    } else if (userModel.status == KTVUserStatusInvite) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_invitation_audience")];
    } else {
        
    }
}

- (void)updateDataLists:(NSArray<KTVUserModel *> *)dataLists
                  model:(KTVUserModel *)model {
    for (int i = 0; i < dataLists.count; i++) {
        KTVUserModel *currentModel = dataLists[i];
        if ([currentModel.uid isEqualToString:model.uid]) {
            NSMutableArray *mutableLists = [[NSMutableArray alloc] initWithArray:dataLists];
            [mutableLists replaceObjectAtIndex:i withObject:model];
            break;
        }
    }
}

- (void)removeDataLists:(NSArray<KTVUserModel *> *)dataLists model:(KTVUserModel *)model {
    KTVUserModel *deleteModel = nil;
    for (int i = 0; i < dataLists.count; i++) {
        KTVUserModel *currentModel = dataLists[i];
        if ([currentModel.uid isEqualToString:model.uid]) {
            deleteModel = currentModel;
            break;
        }
    }

    if (deleteModel) {
        NSMutableArray *mutableLists = [[NSMutableArray alloc] initWithArray:dataLists];
        [mutableLists removeObject:deleteModel];
        dataLists = [mutableLists copy];
    }
}

- (void)maskButtonAction {
    [self dismissUserListView];
}

- (void)dismissUserListView {
    _seatID = @"-1";
    [self.maskButton removeAllSubviews];
    [self.maskButton removeFromSuperview];
    self.maskButton = nil;
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

#pragma mark - Getter

- (KTVRoomRaiseHandListsView *)applyListsView {
    if (!_applyListsView) {
        _applyListsView = [[KTVRoomRaiseHandListsView alloc] init];
        _applyListsView.delegate = self;
        _applyListsView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"];
    }
    return _applyListsView;
}

- (KTVRoomAudienceListsView *)onlineListsView {
    if (!_onlineListsView) {
        _onlineListsView = [[KTVRoomAudienceListsView alloc] init];
        _onlineListsView.delegate = self;
        _onlineListsView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"];
    }
    return _onlineListsView;
}

- (UIButton *)maskButton {
    if (!_maskButton) {
        _maskButton = [[UIButton alloc] init];
        [_maskButton addTarget:self action:@selector(maskButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_maskButton setBackgroundColor:[UIColor clearColor]];
    }
    return _maskButton;
}

- (KTVRoomTopSelectView *)topSelectView {
    if (!_topSelectView) {
        _topSelectView = [[KTVRoomTopSelectView alloc] init];
        _topSelectView.delegate = self;
    }
    return _topSelectView;
}

- (KTVRoomTopSeatView *)topSeatView {
    if (!_topSeatView) {
        _topSeatView = [[KTVRoomTopSeatView alloc] init];
    }
    return _topSeatView;
}

- (void)dealloc {
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

@end
