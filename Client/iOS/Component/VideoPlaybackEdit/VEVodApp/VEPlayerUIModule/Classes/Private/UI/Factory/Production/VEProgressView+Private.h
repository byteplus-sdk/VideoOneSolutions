// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEProgressView.h"
#import "VEInterfaceFactory.h"

@interface VEProgressView () <VEInterfaceFactoryProduction>

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, weak) VEEventPoster *eventPoster;

- (void)setAutoBackStartPoint:(BOOL)autoBackStartPoint;

@end
