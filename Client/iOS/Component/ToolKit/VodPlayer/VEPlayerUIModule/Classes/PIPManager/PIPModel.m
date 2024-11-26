// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PIPModel.h"

@implementation PIPModel

+ (BOOL)getPictureInPicture {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"K_PictureInPicture_Status"];
    return [number boolValue];
}

+ (void)setPictureInPicture:(BOOL)isOpen {
    [[NSUserDefaults standardUserDefaults] setValue:@(isOpen) forKey:@"K_PictureInPicture_Status"];
}

@end
