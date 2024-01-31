//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceElementDescription.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel, VEEventMessageBus, VEEventPoster;

@interface VEInterfaceSocialStackView : UIStackView <VEInterfaceCustomView>

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, weak) VEEventPoster *eventPoster;

- (void)clear;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
