//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LiveCreateRoomControlView;

@protocol LiveCreateRoomControlViewDelegate <NSObject>

- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedSwitchCameraButton:(UIButton *)button;

- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedBeautyButton:(UIButton *)button;

- (void)liveCreateRoomControlView:(LiveCreateRoomControlView *)liveCreateRoomControlView didClickedSettingButton:(UIButton *)button;

@end

@interface LiveCreateRoomControlView : UIView

@property (nonatomic, weak) id<LiveCreateRoomControlViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
