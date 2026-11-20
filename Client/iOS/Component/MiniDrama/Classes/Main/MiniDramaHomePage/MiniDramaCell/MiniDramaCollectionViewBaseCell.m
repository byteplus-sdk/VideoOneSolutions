// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaCollectionViewBaseCell.h"

@implementation MiniDramaCollectionViewBaseCell
- (NSArray<MDDramaInfoModel *> *)visibleDramaInfosInView:(UIView *)viewport {
    return self.dramaInfoModel && CGRectIntersectsRect([self convertRect:self.bounds toView:viewport], viewport.bounds) ? @[self.dramaInfoModel] : @[];
}
- (NSArray<MDDramaInfoModel *> *)adjacentDramaInfosInDirection:(NSInteger)direction { return @[]; }
- (void)notifyScrollWillMove:(UIScrollView *)scrollView {
    if ([self.selectDelegate respondsToSelector:@selector(miniDramaScrollViewWillMove:)]) [self.selectDelegate miniDramaScrollViewWillMove:scrollView];
}
- (void)notifyScrollDidMove:(UIScrollView *)scrollView {
    if ([self.selectDelegate respondsToSelector:@selector(miniDramaScrollViewDidMove:)]) [self.selectDelegate miniDramaScrollViewDidMove:scrollView];
}
- (void)notifyScrollDidStop:(UIScrollView *)scrollView {
    if ([self.selectDelegate respondsToSelector:@selector(miniDramaScrollViewDidStop:)]) [self.selectDelegate miniDramaScrollViewDidStop:scrollView];
}

-(NSString *)formatPlayTimesString:(NSInteger) playTimes {
    if (playTimes < 10000) {
        return [NSString stringWithFormat:@"%ld", playTimes];
    } else {
        return [NSString stringWithFormat:@"%.1fw", playTimes/10000.0];
    }
}

@end
