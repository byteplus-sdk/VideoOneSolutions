// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEActionButton.h"
#import "VEInterfaceFactory.h"

@interface VEActionButton () <VEInterfaceFactoryProduction>

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, weak) VEEventPoster *eventPoster;

@end
