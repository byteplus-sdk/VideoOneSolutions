//
//  MiniDramaCollectionViewBaseCell.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/20.
//

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
