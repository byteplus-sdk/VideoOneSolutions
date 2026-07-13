//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceElementDescription.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEEventPoster;

@interface AirPlayRoutePickerView : UIView <VEInterfaceCustomView>

@property (nonatomic, weak) VEEventPoster *eventPoster;

- (void)updateHidden;

@end

NS_ASSUME_NONNULL_END
