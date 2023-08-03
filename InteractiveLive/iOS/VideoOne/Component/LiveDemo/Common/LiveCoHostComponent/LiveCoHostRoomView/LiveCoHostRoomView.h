// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveRTCManager.h"
#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveCoHostRoomView : UIView

@property (nonatomic, copy) NSArray<LiveUserModel *> *userModelList;

- (instancetype)initWithRenderSize:(CGSize)renderSize
                     roomInfoModel:(LiveRoomInfoModel *)roomInfoModel;

- (void)startTime;

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid;

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid;

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
