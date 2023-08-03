// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsRoomView.h"
#import "LiveStateIconView.h"
#import "LiveSettingVideoConfig.h"
#import "LiveTimeView.h"
#import "LiveAddGuestsTwoRenderView.h"
#import "LiveAddGuestsMultiRenderView.h"

@interface LiveAddGuestsRoomView ()

@property (nonatomic, strong) LiveTimeView *timeView;
@property (nonatomic, strong) LiveStateIconView *netQualityView;
@property (nonatomic, strong) LiveStateIconView *micView;
@property (nonatomic, strong) LiveStateIconView *cameraView;
@property (nonatomic, strong) LiveAddGuestsTwoRenderView *twoRenderView;
@property (nonatomic, strong) LiveAddGuestsMultiRenderView *multiRenderView;

@property (nonatomic, copy) NSArray<LiveUserModel *> *userList;
@property (nonatomic, copy) NSString *hostID;
@property (nonatomic, strong) LiveRoomInfoModel *roomInfoModel;

@end

@implementation LiveAddGuestsRoomView

- (instancetype)initWithHostID:(NSString *)hostID
                 roomInfoModel:(LiveRoomInfoModel *)roomInfoModel {
    self = [super init];
    if (self) {
        _roomInfoModel = roomInfoModel;
        _hostID = hostID;
        [self addSubviewConstraints];
        [self.timeView updateLiveTime:roomInfoModel.startTime];
        
        __weak __typeof(self) wself = self;
        self.twoRenderView.clickSmallBlock = ^(LiveUserModel * _Nonnull userModel) {
            if ([wself.delegate respondsToSelector:@selector(guestsRoomView:clickMoreButton:)]) {
                [wself.delegate guestsRoomView:wself clickMoreButton:userModel];
            }
        };
        
        self.multiRenderView.clickUserBlock = ^(LiveUserModel * _Nonnull userModel) {
            if ([wself.delegate respondsToSelector:@selector(guestsRoomView:clickMultiUser:)]) {
                [wself.delegate guestsRoomView:wself
                                clickMultiUser:userModel];
            }
        };
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateGuests:(NSArray<LiveUserModel *> *)userList {
    _userList = userList;
    
    NSArray *sortUserList = [self sortHostUserModel:userList];
    if (sortUserList.count <= 2) {
        [self.twoRenderView updateUserList:sortUserList];
        self.twoRenderView.hidden = NO;
        self.multiRenderView.hidden = YES;
    } else {
        [self.multiRenderView updateUserList:sortUserList];
        self.twoRenderView.hidden = YES;
        self.multiRenderView.hidden = NO;
    }
}

- (void)removeGuests:(NSString *)uid {
    LiveUserModel *deleteUserModel = nil;
    
    for (LiveUserModel *userModel in self.userList) {
        if ([userModel.uid isEqualToString:uid]) {
            deleteUserModel = userModel;
            break;
        }
    }
    if (deleteUserModel) {
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.userList];
        [list removeObject:deleteUserModel];
        self.userList = [list copy];
    }
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    if ([uid isEqualToString:self.hostID]) {
        self.micView.hidden = mic;

        CGFloat top = self.micView.hidden ? 75 + [DeviceInforTool getStatusBarHight] : 100 + [DeviceInforTool getStatusBarHight];
        [self.cameraView mas_updateConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(top);
        }];

        if ([uid isEqualToString:[LocalUserComponent userModel].uid]) {
            [[LiveRTCManager shareRtc] switchAudioCapture:mic];
        }
    } else {
        if (!self.twoRenderView.hidden) {
            [self.twoRenderView updateGuestsMic:mic uid:uid];
        }
        if (!self.multiRenderView.hidden) {
            [self.multiRenderView updateGuestsMic:mic uid:uid];
        }
    }
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    if ([uid isEqualToString:self.hostID]) {
        self.cameraView.hidden = camera;
    }
    if (!self.twoRenderView.hidden) {
        [self.twoRenderView updateGuestsCamera:camera uid:uid];
    }
    if (!self.multiRenderView.hidden) {
        [self.multiRenderView updateGuestsCamera:camera uid:uid];
    }
}

- (BOOL)getIsGuests:(NSString *)uid {
    BOOL isGuests = NO;
    for (LiveUserModel *userModel in self.userList) {
        if ([userModel.uid isEqualToString:uid]) {
            isGuests = YES;
            break;
        }
    }
    return isGuests;
}

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status uid:(NSString *)uid {
    if ([uid isEqualToString:self.hostID]) {
        if (status == LiveNetworkQualityStatusGood) {
            [self.netQualityView updateState:LiveIconStateNetQuality];
        } else if (status == LiveNetworkQualityStatusNone) {
            [self.netQualityView updateState:LiveIconStateHidden];
        } else {
            [self.netQualityView updateState:LiveIconStateNetQualityBad];
        }
    }
}

#pragma mark - Private Action

- (NSArray<LiveUserModel *> *)removeHostUserModel:(NSArray<LiveUserModel *> *)userModelList {
    NSMutableArray *mutableList = [userModelList mutableCopy];
    LiveUserModel *hostUserModel = nil;
    for (LiveUserModel *userModel in userModelList) {
        if ([userModel.uid isEqualToString:self.hostID]) {
            hostUserModel = userModel;
        }
    }
    if (hostUserModel) {
        [mutableList removeObject:hostUserModel];
    }
    return [mutableList copy];
}

- (NSArray *)sortHostUserModel:(NSArray<LiveUserModel *> *)userModelList {
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:userModelList];
    LiveUserModel *hostUserModel = nil;
    for (LiveUserModel *userModel in userModelList) {
        if ([userModel.uid isEqualToString:self.hostID]) {
            hostUserModel = userModel;
        }
    }
    if (hostUserModel) {
        [list removeObject:hostUserModel];
        [list insertObject:hostUserModel atIndex:0];
    }
    return [list copy];
}

- (void)addSubviewConstraints {
    [self addSubview:self.twoRenderView];
    [self.twoRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.multiRenderView];
    [self.multiRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(76 + [DeviceInforTool getStatusBarHight]);
        make.bottom.mas_equalTo(-(46 + [DeviceInforTool getVirtualHomeHeight]));
        make.left.right.equalTo(self);
    }];
    
    [self addSubview:self.timeView];
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(50 + [DeviceInforTool getStatusBarHight]);
    }];

    [self addSubview:self.netQualityView];
    [self.netQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self.timeView.mas_right).offset(6);
        make.centerY.equalTo(self.timeView);
    }];

    [self addSubview:self.micView];
    [self.micView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.left.equalTo(self.netQualityView);
        make.top.mas_equalTo(75 + [DeviceInforTool getStatusBarHight]);
    }];

    [self addSubview:self.cameraView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.left.equalTo(self.netQualityView);
        make.top.mas_equalTo(100 + [DeviceInforTool getStatusBarHight]);
    }];
}

- (BOOL)isHost {
    BOOL isHost = [self.hostID isEqualToString:[LocalUserComponent userModel].uid];
    return isHost;
}

#pragma mark - Getter

- (LiveTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[LiveTimeView alloc] init];
        _timeView.hidden = [self isHost] == NO;
    }
    return _timeView;
}

- (LiveAddGuestsTwoRenderView *)twoRenderView {
    if (!_twoRenderView) {
        _twoRenderView = [[LiveAddGuestsTwoRenderView alloc] initWithRoomInfoModel:self.roomInfoModel];
        _twoRenderView.backgroundColor = [UIColor clearColor];
        _twoRenderView.hidden = YES;
    }
    return _twoRenderView;
}

- (LiveAddGuestsMultiRenderView *)multiRenderView {
    if (!_multiRenderView) {
        BOOL isHost = [self isHost];
        _multiRenderView = [[LiveAddGuestsMultiRenderView alloc] initWithIsHost:isHost];
        _multiRenderView.hidden = YES;
    }
    return _multiRenderView;
}

- (LiveStateIconView *)netQualityView {
    if (!_netQualityView) {
        _netQualityView = [[LiveStateIconView alloc] initWithState:LiveIconStateHidden];
        _netQualityView.hidden = [self isHost] == NO;
    }
    return _netQualityView;
}

- (LiveStateIconView *)micView {
    if (!_micView) {
        _micView = [[LiveStateIconView alloc] initWithState:LiveIconStateMic];
        _micView.hidden = YES;
        _micView.alpha = 0;
    }
    return _micView;
}

- (LiveStateIconView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[LiveStateIconView alloc] initWithState:LiveIconStateCamera];
        _cameraView.hidden = YES;
        _cameraView.alpha = 0;
    }
    return _cameraView;
}

@end
