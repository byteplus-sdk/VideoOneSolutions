// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceElementDescriptionImp.h"
#import "MDInterfaceElementProtocol.h"

extern NSString *const mdprogressViewId;

extern NSString *const mdprogressGestureId;

@interface MDInterfaceProgressElement : NSObject <MDInterfaceElementProtocol>

+ (MDInterfaceElementDescriptionImp *)progressView;

+ (MDInterfaceElementDescriptionImp *)progressGesture;

@end
