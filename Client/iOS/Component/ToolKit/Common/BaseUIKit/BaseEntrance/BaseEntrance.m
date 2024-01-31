// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseEntrance.h"

@implementation BaseEntrance

- (void)enterWithCallback:(void (^)(BOOL result))block {
    // subclass override
}

@end

@implementation BaseSceneEntrance

+ (void)prepareEnvironment {
}

@end

@implementation BaseFunctionEntrance

@end

@implementation BaseFunctionSection

@end
