// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "LiveUserModel.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PullRenderStatus) {
    // Single anchor & audience mic mode
    PullRenderStatusNone = 0,
    // PK mode
    PullRenderStatusPK,
    // Single anchor & audience mic mode
    PullRenderStatusTwoCoHost,
    // Single anchor & audience mic mode
    PullRenderStatusMultiCoHost,
};

NS_ASSUME_NONNULL_BEGIN

@interface LivePullRenderView : UIView

@property (nonatomic, strong) UIView *streamView;

@property (nonatomic, copy) NSString *hostUid;

@property (nonatomic, assign) PullRenderStatus status;

- (void)updateHostMic:(BOOL)mic camera:(BOOL)camera;

@end

NS_ASSUME_NONNULL_END
