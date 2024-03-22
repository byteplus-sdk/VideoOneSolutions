//
//  KTVSeatComponent.m
//  veRTC_Demo
//
//  Created by on 2021/12/1.
//  
//

#import "KTVSeatComponent.h"
#import "KTVSeatView.h"
#import "KTVRTSManager.h"

@interface KTVSeatComponent () <KTVSheetViewDelegate>

@property (nonatomic, weak) KTVSeatView *seatView;
@property (nonatomic, weak) KTVSheetView *sheetView;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) KTVUserModel *loginUserModel;

@end

@implementation KTVSeatComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
    }
    return self;
}

#pragma mark - Publish Action

- (void)showSeatView:(NSArray<KTVSeatModel *> *)seatList
      loginUserModel:(KTVUserModel *)loginUserModel {
    _loginUserModel = loginUserModel;
    
    if (!_seatView) {
        CGFloat space = (SCREEN_WIDTH - 32 * 7 - 1)/9;
        KTVSeatView *seatView = [[KTVSeatView alloc] init];
        [_superView addSubview:seatView];
        [seatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_superView);
            make.right.equalTo(_superView).offset(-space);
            make.size.mas_equalTo(CGSizeMake(32*6 + space*5, 54));
        }];
        _seatView = seatView;
    }
    _seatView.seatList = seatList;
    
    __weak __typeof(self) wself = self;
    _seatView.clickBlock = ^(KTVSeatModel * _Nonnull seatModel) {
        KTVSheetView *sheetView = [[KTVSheetView alloc] init];
        sheetView.delegate = wself;
        [wself.superView.superview addSubview:sheetView];
        [sheetView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself.superView.superview);
        }];
        [sheetView showWithSeatModel:seatModel
                      loginUserModel:wself.loginUserModel];
        wself.sheetView = sheetView;
    };
}

- (void)addSeatModel:(KTVSeatModel *)seatModel {
    [_seatView addSeatModel:seatModel];
    [self updateSeatModel:seatModel];
}

- (void)removeUserModel:(KTVUserModel *)userModel {
    [_seatView removeUserModel:userModel];
    if ([userModel.uid isEqualToString:_loginUserModel.uid]) {
        _loginUserModel = userModel;
    }
    NSString *sheetUid = self.sheetView.seatModel.userModel.uid;
    if (self.sheetView &&
        [userModel.uid isEqualToString:sheetUid]) {
        // update the new one to open the sheet user
        [self.sheetView dismiss];
    }
}

- (void)updateSeatModel:(KTVSeatModel *)seatModel {
    [_seatView updateSeatModel:seatModel];
    if ([seatModel.userModel.uid isEqualToString:_loginUserModel.uid]) {
        _loginUserModel = seatModel.userModel;
    }
    NSString *sheetUid = self.sheetView.seatModel.userModel.uid;
    if (self.sheetView &&
        [seatModel.userModel.uid isEqualToString:sheetUid]) {
        // update the new one to open the sheet user
        [self.sheetView dismiss];
    }
}

- (void)updateSeatVolume:(NSDictionary *)volumeDic {
    [_seatView updateSeatVolume:volumeDic];
}

- (void)updateCurrentSongModel:(KTVSongModel *)songModel {
    [_seatView updateCurrentSongModel:songModel];
}

- (void)dismissSheetView {
    if (self.sheetView) {
        [self.sheetView dismiss];
    }
}

- (void)dismissSheetViewWithSeatId:(NSString *)seatId {
    if ([@(self.sheetView.seatModel.index).stringValue isEqualToString:seatId]) {
        [self dismissSheetView];
    }
}

#pragma mark - KTVSheetViewDelegate

- (void)sheetView:(KTVSheetView *)sheetView
      clickButton:(KTVSheetStatus)sheetState {
    if (sheetState == KTVSheetStatusInvite) {
        if ([self.delegate respondsToSelector:@selector
             (seatComponent:clickButton:sheetStatus:)]) {
            [self.delegate seatComponent:self
                             clickButton:sheetView.seatModel
                             sheetStatus:sheetState];
        }
        [sheetView dismiss];
    } else if (sheetState == KTVSheetStatusKick) {
        [self loadDataManager:5 sheetView:sheetView];
    } else if (sheetState == KTVSheetStatusOpenMic) {
        [self loadDataManager:4 sheetView:sheetView];
    } else if (sheetState == KTVSheetStatusCloseMic) {
        [self loadDataManager:3 sheetView:sheetView];
    } else if (sheetState == KTVSheetStatusLock) {
        [self showAlertWithLockSeat:sheetView];
    } else if (sheetState == KTVSheetStatusUnlock) {
        [self loadDataManager:2 sheetView:sheetView];
    } else if (sheetState == KTVSheetStatusApply) {
        [self loadDataApply:sheetView];
    } else if (sheetState == KTVSheetStatusLeave) {
        [self loadDataLeave:sheetView];
    } else {
        //error
    }
}

#pragma mark - Private Action

- (void)loadDataManager:(NSInteger)type
              sheetView:(KTVSheetView *)KTVSheetView {
    [[ToastComponent shareToastComponent] showLoading];
    NSString *seatID = [NSString stringWithFormat:@"%ld", (long)KTVSheetView.seatModel.index];
    [KTVRTSManager managerSeat:KTVSheetView.loginUserModel.roomID
                                     seatID:seatID
                                       type:type
                         block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"operation_failed_message")];
        } else {
            [KTVSheetView dismiss];
        }
    }];
}

- (void)loadDataApply:(KTVSheetView *)KTVSheetView {
    [[ToastComponent shareToastComponent] showLoading];
    NSString *seatID = [NSString stringWithFormat:@"%ld", (long)KTVSheetView.seatModel.index];
    [KTVRTSManager applyInteract:KTVSheetView.loginUserModel.roomID
                                       seatID:seatID
                                        block:^(BOOL isNeedApply, RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        } else {
            if (isNeedApply) {
                KTVSheetView.loginUserModel.status = KTVUserStatusApply;
                [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_apply_guest")];
            }
            [KTVSheetView dismiss];
        }
    }];
}

- (void)loadDataLeave:(KTVSheetView *)KTVSheetView {
    [[ToastComponent shareToastComponent] showLoading];
    NSString *seatID = [NSString stringWithFormat:@"%ld", (long)KTVSheetView.seatModel.index];
    [KTVRTSManager finishInteract:KTVSheetView.loginUserModel.roomID
                                        seatID:seatID
                                         block:^(RTSACKModel * _Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"operation_failed_message")];
        } else {
            [KTVSheetView dismiss];
        }
    }];
}

- (void)showAlertWithLockSeat:(KTVSheetView *)KTVSheetView {
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedString(@"ok");
    AlertActionModel *cancelModel = [[AlertActionModel alloc] init];
    cancelModel.title = LocalizedString(@"cancel");
    [[AlertActionManager shareAlertActionManager] showWithMessage:LocalizedString(@"toast_lock_seat") actions:@[ cancelModel, alertModel ]];
    __weak __typeof(self) wself = self;
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if ([action.title isEqualToString:LocalizedString(@"ok")]) {
            [wself loadDataManager:1 sheetView:KTVSheetView];
        }
    };
}



@end
