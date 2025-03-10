// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceSimpleMethodSceneConf.h"
#import "MDInterfacePlayElement.h"
#import "MDInterfaceProgressElement.h"

@implementation MDInterfaceSimpleMethodSceneConf

- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements {
    return @[
        [MDInterfacePlayElement playButton],
        [MDInterfacePlayElement playGesture], 
        [MDInterfaceProgressElement progressView],
    ];
}

@end
