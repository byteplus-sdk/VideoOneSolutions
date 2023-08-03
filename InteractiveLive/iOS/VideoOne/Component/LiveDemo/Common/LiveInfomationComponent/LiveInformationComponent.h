// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "LiveRtcLinkSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveInformationComponent : NSObject

- (instancetype)initWithView:(UIView *)superView;

@property (nonatomic, weak) LiveRtcLinkSession *linkSession;

- (void)show;

@end

NS_ASSUME_NONNULL_END
