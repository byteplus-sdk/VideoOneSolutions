// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfaceElementProtocol.h"

extern NSString *const progressViewId;

extern NSString *const progressGestureId;

@class VEEventPoster;
@interface VEInterfaceProgressElement : NSObject <VEInterfaceElementProtocol>

+ (VEInterfaceElementDescriptionImp *)progressViewWithEventPoster:(VEEventPoster *)eventPoster;

+ (VEInterfaceElementDescriptionImp *)progressGestureWithEventPoster:(VEEventPoster *)eventPoster;

@end
