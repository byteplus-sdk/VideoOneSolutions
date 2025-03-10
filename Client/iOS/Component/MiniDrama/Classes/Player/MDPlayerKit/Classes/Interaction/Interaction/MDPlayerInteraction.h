// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerViewLifeCycleProtocol.h"
#import "MDPlayerModuleManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerViewLifeCycleProtocol;

@protocol MDPlayerInteractionPlayerProtocol <MDPlayerViewLifeCycleProtocol, MDPlayerModuleManagerInterface>

@end

@class MDPlayerContext;

@interface MDPlayerInteraction : NSObject <MDPlayerInteractionPlayerProtocol>

@property (nonatomic, weak) UIView *playerContainerView;
@property (nonatomic, weak) UIView *playerVCView;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContext:(MDPlayerContext *)context NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
