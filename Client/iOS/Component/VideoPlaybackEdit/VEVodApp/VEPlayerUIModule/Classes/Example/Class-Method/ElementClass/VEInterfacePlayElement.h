// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfaceElementProtocol.h"

extern NSString *const playButtonId;

extern NSString *const playGestureId;

extern NSString *const likeGestureId;

@class VEEventPoster;
@interface VEInterfacePlayElement : NSObject <VEInterfaceElementProtocol>

+ (VEInterfaceElementDescriptionImp *)playButtonWithEventPoster:(VEEventPoster *)eventPoster;

+ (VEInterfaceElementDescriptionImp *)playGestureWithEventPoster:(VEEventPoster *)eventPoster;

+ (VEInterfaceElementDescriptionImp *)likeGesture;

+ (VEInterfaceElementDescriptionImp *)autoHideControllerGesture;

@end
