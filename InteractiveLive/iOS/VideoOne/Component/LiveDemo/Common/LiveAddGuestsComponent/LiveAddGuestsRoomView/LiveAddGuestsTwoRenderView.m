// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsTwoRenderView.h"
#import "LiveAddGuestsItemView.h"
#import "LiveRTCRenderView.h"

@interface LiveAddGuestsTwoRenderView ()

@property (nonatomic, strong) LiveRTCRenderView *bigRenderView;
@property (nonatomic, strong) LiveAddGuestsItemView *smallRenderView;
@property (nonatomic, assign) BOOL isSwitch;
@property (nonatomic, copy) NSArray<LiveUserModel *> *userList;
@property (nonatomic, strong) LiveRoomInfoModel *roomInfoModel;

@end

@implementation LiveAddGuestsTwoRenderView

- (instancetype)initWithRoomInfoModel:(LiveRoomInfoModel *)roomInfoModel {
    self = [super init];
    if (self) {
        self.roomInfoModel = roomInfoModel;
        self.isSwitch = NO;
        [self addSubview:self.bigRenderView];
        [self.bigRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.smallRenderView];
        [self.smallRenderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, 120));
            make.right.mas_equalTo(-12);
            make.bottom.mas_equalTo(-(68 + [DeviceInforTool getVirtualHomeHeight]));
        }];
        
        __weak __typeof(self) wself = self;
        self.smallRenderView.clickMoreBlock = ^(LiveUserModel *userModel) {
            if (wself.clickSmallBlock) {
                wself.clickSmallBlock(userModel);
            }
        };
        self.smallRenderView.clickMaskBlock = ^(LiveUserModel * _Nonnull userModel) {
            [wself switchRenderView];
        };
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateUserList:(NSArray<LiveUserModel *> *)userList {
    if (userList.count <= 0) {
        return;
    }
    self.userList = userList;
    self.bigRenderView.uid = userList[0].uid;
    self.smallRenderView.userModel = userList.lastObject;
    for (LiveUserModel *userModel in userList) {
        [self updateGuestsMic:userModel.mic uid:userModel.uid];
        [self updateGuestsCamera:userModel.camera uid:userModel.uid];
    }
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    LiveUserModel *curModel = nil;
    for (LiveUserModel *model in self.userList) {
        if ([model.uid isEqualToString:uid]) {
            model.mic = mic;
            curModel = model;
            break;
        }
    }
    if ([self.smallRenderView.userModel.uid isEqualToString:uid] &&
        curModel) {
        self.smallRenderView.userModel = curModel;
    }
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    LiveUserModel *curModel = nil;
    for (LiveUserModel *model in self.userList) {
        if ([model.uid isEqualToString:uid]) {
            model.camera = camera;
            curModel = model;
            break;
        }
    }
    if ([self.smallRenderView.userModel.uid isEqualToString:uid] &&
        curModel) {
        self.smallRenderView.userModel = curModel;
    } else {
        self.bigRenderView.isCamera = curModel.camera;
    }
}

#pragma mark - Private Action

- (void)switchRenderView {
    
    if (self.isSwitch) {
        self.bigRenderView.uid = self.userList.lastObject.uid;
        self.smallRenderView.userModel = self.userList[0];
    } else {
        self.bigRenderView.uid = self.userList[0].uid;
        self.smallRenderView.userModel = self.userList.lastObject;
    }
    
    self.isSwitch = !self.isSwitch;
}

- (void)bigRenderViewAction {
//    [self switchRenderView];
}

#pragma mark - Getter

- (LiveRTCRenderView *)bigRenderView {
    if (!_bigRenderView) {
        _bigRenderView = [[LiveRTCRenderView alloc] init];
        _bigRenderView.backgroundColor = [UIColor clearColor];
        
        _bigRenderView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigRenderViewAction)];
        [_bigRenderView addGestureRecognizer:tap];
    }
    return _bigRenderView;
}

- (LiveAddGuestsItemView *)smallRenderView {
    if (!_smallRenderView) {
        BOOL isHost = [self.roomInfoModel.anchorUserID isEqualToString:[LocalUserComponent userModel].uid];
        LiveAddGuestsItemStatus status = isHost ? LiveAddGuestsItemStatusTwoPlayerHost : LiveAddGuestsItemStatusTwoPlayerGuests;
        _smallRenderView = [[LiveAddGuestsItemView alloc] initWithStatus:status];
        _smallRenderView.backgroundColor = [UIColor clearColor];
    }
    return _smallRenderView;
}

@end
