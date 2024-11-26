// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "PublicParameterComponent.h"
#import "LocalUserComponent.h"

@implementation PublicParameterComponent

+ (PublicParameterComponent *)share {
    static dispatch_once_t onceToken;
    static PublicParameterComponent *publicParameterComponent;
    dispatch_once(&onceToken, ^{
        publicParameterComponent = [[PublicParameterComponent alloc] init];
    });
    return publicParameterComponent;
}

+ (void)clear {
    [PublicParameterComponent share].appId = @"";
}

@end
