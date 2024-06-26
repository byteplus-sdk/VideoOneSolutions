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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isNeedShow = YES;
        self.marginTop = 8;
        self.marginBottom = 8;
        self.height = 58;
    }
    return self;
}

@end

@implementation BaseFunctionSection

@end


@implementation BaseFunctionDataList


@end
