// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController.h"
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (DebugTool)

@property (nonatomic, strong) TTVideoEngineDebugTools *videoEngineDebugTool; // debug tool

- (void)showDebugViewInView:(UIView *)hudView;

- (void)removeDebugTool;

+ (NSString *)deviceID;

@end

NS_ASSUME_NONNULL_END
