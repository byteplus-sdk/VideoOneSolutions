//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCManager.h"
#import "LiveRTCRenderView.h"
#import "LiveUserModel.h"

typedef NS_ENUM(NSInteger, LiveAddGuestsItemStatus) {
    LiveAddGuestsItemStatusTwoPlayerHost,
    LiveAddGuestsItemStatusTwoPlayerGuests,
    LiveAddGuestsItemStatusMultiPlayer,
};

NS_ASSUME_NONNULL_BEGIN

@interface LiveAddGuestsItemView : UIView

@property (nonatomic, strong) LiveUserModel *userModel;

@property (nonatomic, copy) void (^clickMoreBlock)(LiveUserModel *userModel);

@property (nonatomic, copy) void (^clickMaskBlock)(LiveUserModel *userModel);

@property (nonatomic, assign) BOOL isHost;

- (instancetype)initWithStatus:(LiveAddGuestsItemStatus)status;

- (void)updateNetworkQuality:(LiveNetworkQualityStatus)status;

- (void)updateAddTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
