//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const VEInterPlayButtonIdentifier;

extern NSString *const VEProgressViewIdentifier;

extern NSString *const VEInterFullScreenButtonIdentifier;

@class VEEventMessageBus, VEEventPoster, VEInterfaceElementDescriptionImp, VEMultiStatePlayButton;

@interface VEInterfaceBaseElementConf : NSObject

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

- (VEInterfaceElementDescriptionImp *)playButton;

- (VEInterfaceElementDescriptionImp *)progressView;

- (VEInterfaceElementDescriptionImp *)fullScreenButton;

- (VEInterfaceElementDescriptionImp *)autoHideControllerGesture;

- (VEInterfaceElementDescriptionImp *)clearScreenGesture;

- (void)updatePlayButtonState:(VEMultiStatePlayButton *)button;

@end

NS_ASSUME_NONNULL_END
