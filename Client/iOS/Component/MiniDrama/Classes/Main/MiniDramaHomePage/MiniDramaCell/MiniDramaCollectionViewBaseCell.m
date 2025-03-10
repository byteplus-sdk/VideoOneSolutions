// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaCollectionViewBaseCell.h"

@implementation MiniDramaCollectionViewBaseCell

-(NSString *)formatPlayTimesString:(NSInteger) playTimes {
    if (playTimes < 10000) {
        return [NSString stringWithFormat:@"%ld", playTimes];
    } else {
        return [NSString stringWithFormat:@"%.1fw", playTimes/10000.0];
    }
}

@end
