// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsMultiRenderView.h"
#import "LiveAddGuestsItemView.h"
#import "LiveRTCRenderView.h"

static NSInteger const MaxItemNumber = 6;

@interface LiveAddGuestsMultiRenderView ()

@property (nonatomic, strong) LiveRTCRenderView *bigRenderView;
@property (nonatomic, copy) NSArray *itemList;
@property (nonatomic, assign) BOOL isHost;

@end

@implementation LiveAddGuestsMultiRenderView

- (instancetype)initWithIsHost:(BOOL)isHost {
    self = [super init];
    if (self) {
        self.isHost = isHost;
        NSMutableArray<LiveAddGuestsItemView *> *itemList = [[NSMutableArray alloc] init];
        for (int i = 0; i < MaxItemNumber; i++) {
            LiveAddGuestsItemView *itemView = [[LiveAddGuestsItemView alloc] initWithStatus:LiveAddGuestsItemStatusMultiPlayer];
            //yuobyang
            NSString *title = isHost ? @"Add guest" : @"Join";
            [itemView updateAddTitle:title];
            itemView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.1 * 255];
            [itemList addObject:itemView];
            [self addSubview:itemView];
            
            __weak __typeof(self) wself = self;
            itemView.clickMaskBlock = ^(LiveUserModel * _Nonnull userModel) {
                if (wself.clickUserBlock) {
                    wself.clickUserBlock(userModel);
                }
            };
        }
        self.itemList = [itemList copy];
        
        [self addSubview:self.bigRenderView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemHeight = (self.height - ((MaxItemNumber - 1) * 2)) / 6;
    [self.itemList mas_distributeViewsAlongAxis:MASAxisTypeVertical
                       withFixedItemLength:itemHeight
                               leadSpacing:0
                               tailSpacing:0];
    [self.itemList mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.mas_equalTo(itemHeight);
    }];
    
    [self.bigRenderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(2 + itemHeight));
        make.left.top.bottom.equalTo(self);
    }];
}

#pragma mark - Publish Action

- (void)updateUserList:(NSArray<LiveUserModel *> *)userList {
    LiveUserModel *hostUserModel = userList[0];
    self.bigRenderView.uid = hostUserModel.uid;
    [self updateGuestsMic:hostUserModel.mic uid:hostUserModel.uid];
    [self updateGuestsCamera:hostUserModel.camera uid:hostUserModel.uid];
    
    for (int i = 0; i < self.itemList.count; i++) {
        LiveAddGuestsItemView *itemView = self.itemList[i];
        if (i + 1 < userList.count) {
            LiveUserModel *userModel = userList[i + 1];
            itemView.userModel = userModel;
            [self updateGuestsMic:userModel.mic uid:userModel.uid];
            [self updateGuestsCamera:userModel.camera uid:userModel.uid];
        } else {
            itemView.userModel = [LiveUserModel new];
            itemView.isHost = self.isHost;
        }
    }
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    for (LiveAddGuestsItemView *itemView in self.itemList) {
        if ([itemView.userModel.uid isEqualToString:uid]) {
            LiveUserModel *curUserModel = itemView.userModel;
            curUserModel.mic = mic;
            itemView.userModel = curUserModel;
            break;
        }
    }
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    if ([self.bigRenderView.uid isEqualToString:uid]) {
        self.bigRenderView.isCamera = camera;
    } else {
        for (LiveAddGuestsItemView *itemView in self.itemList) {
            if ([itemView.userModel.uid isEqualToString:uid]) {
                LiveUserModel *curUserModel = itemView.userModel;
                curUserModel.camera = camera;
                itemView.userModel = curUserModel;
                break;
            }
        }
    }
}

#pragma mark - Getter

- (NSArray<LiveAddGuestsItemView *> *)itemList {
    if (!_itemList) {
        _itemList = [[NSArray alloc] init];
    }
    return _itemList;
}

- (LiveRTCRenderView *)bigRenderView {
    if (!_bigRenderView) {
        _bigRenderView = [[LiveRTCRenderView alloc] init];
        _bigRenderView.backgroundColor = [UIColor clearColor];
    }
    return _bigRenderView;
}


@end
