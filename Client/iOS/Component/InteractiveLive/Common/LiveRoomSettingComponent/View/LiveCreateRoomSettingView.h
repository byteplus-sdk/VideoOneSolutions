//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingVideoConfig.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LiveCreateRoomSettingView;

@protocol LiveCreateRoomSettingViewDelegate <NSObject>

- (void)liveCreateRoomSettingView:(LiveCreateRoomSettingView *)settingView didChangefpsType:(LiveSettingVideoFpsType)fpsType;

- (void)liveCreateRoomSettingView:(LiveCreateRoomSettingView *)settingView didChangeBitrate:(NSInteger)bitrate;

- (void)liveCreateRoomSettingView:(LiveCreateRoomSettingView *)settingView
                 didSelectQuality:(BOOL)isSelect;

@end

@interface LiveCreateRoomSettingView : UIView

@property (nonatomic, weak) id<LiveCreateRoomSettingViewDelegate> delegate;

@property (nonatomic, strong) LiveSettingVideoConfig *videoConfig;

@end

NS_ASSUME_NONNULL_END
