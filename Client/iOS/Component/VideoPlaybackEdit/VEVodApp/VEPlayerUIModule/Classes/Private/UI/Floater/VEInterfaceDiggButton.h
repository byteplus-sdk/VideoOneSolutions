//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceSocialButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEInterfaceDiggButton : VEInterfaceSocialButton

@property (nonatomic, assign) BOOL liked;

- (void)play;

+ (void)playDiggAnimationInView:(UIView *)containerView location:(CGPoint)location;

@end

NS_ASSUME_NONNULL_END
