// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import <TTSDKFramework/TTSDKFramework.h>

@interface TTVideoEngineVidSource (MDVidSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) NSInteger startTime;

@end

@interface TTVideoEngineUrlSource (MDUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, assign) NSInteger startTime;

@end

