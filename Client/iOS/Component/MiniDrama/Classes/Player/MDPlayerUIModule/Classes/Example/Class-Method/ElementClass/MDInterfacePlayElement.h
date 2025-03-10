// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceElementDescriptionImp.h"
#import "MDInterfaceElementProtocol.h"

extern NSString *const mdplayButtonId;

extern NSString *const mdplayGestureId;

@interface MDInterfacePlayElement : NSObject <MDInterfaceElementProtocol>

+ (MDInterfaceElementDescriptionImp *)playButton;

+ (MDInterfaceElementDescriptionImp *)playGesture;

@end


