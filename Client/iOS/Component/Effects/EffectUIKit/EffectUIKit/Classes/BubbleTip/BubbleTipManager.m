// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BubbleTipManager.h"
#import "BubbleTipView.h"
#import <Masonry/Masonry.h>

static const int TIP_HEIGHT = 40;
static const double ANIMATION_DURATION = 0.2;
static const int MAX_SHOWING_TIP = 1;

@interface BubbleTipManager ()

@property (nonatomic, strong) NSMutableArray<BubbleTipView *> *showingView;
@property (nonatomic, strong) NSMutableArray<BubbleTipView *> *cachedView;

@end

@implementation BubbleTipManager

- (instancetype)initWithContainer:(UIView *)container topMargin:(int)topMargin {
    self = [super init];
    if (self) {
        _container = container;
        _topMargin = topMargin;
        
        _showingView = [NSMutableArray array];
        _cachedView = [NSMutableArray array];
    }
    return self;
}

- (void)showBubble:(NSString *)title desc:(NSString *)desc duration:(NSTimeInterval)duration {
    BubbleTipView *view = [self getBubbleView];
    
    int tipIndex = [self getAvailableIndex];
    view.tipIndex = tipIndex;
    view.frame = [self getFrameWithIndex:tipIndex];
    
    [self updateBubble:view title:title desc:desc];
    
    [self show:view duration:duration];
}

#pragma mark - private
- (BubbleTipView *)getBubbleView {
    if (self.showingView.count >= MAX_SHOWING_TIP) {
        BubbleTipView *view = [self.showingView lastObject];
        [self.showingView removeLastObject];
        if (view != nil) {
            if (view.completeBlock != nil && !view.blockInvoked) {
                dispatch_block_cancel(view.completeBlock);
                view.needReshow = NO;
                return view;
            } else {
                // 如果 block 已经被调用，它便无法被取消了，意味着 ANIMATION_DURATION
                // 时间之后这个 view 必然会被回收，所以只能重新找一个新的 view 来用了
                [view removeFromSuperview];
            }
        }
    }
    
    if (self.cachedView.count > 0) {
        BubbleTipView *view = self.cachedView.lastObject;
        [self.cachedView removeLastObject];
        view.needReshow = YES;
        return view;
    }
    
    return [BubbleTipView new];
}

- (void)recycleView:(BubbleTipView *)view {
    [view removeFromSuperview];
    view.completeBlock = nil;
    [self.showingView removeObject:view];
    [self.cachedView addObject:view];
}

- (int)getAvailableIndex {
    NSMutableSet<NSNumber *> *usingIndex = [NSMutableSet set];
    for (BubbleTipView *view in self.showingView) {
        [usingIndex addObject:[NSNumber numberWithInteger:view.tipIndex]];
    }
    
    int i = 0;
    for (; i < usingIndex.count; i++) {
        if (![usingIndex containsObject:[NSNumber numberWithInt:i]]) {
            break;
        }
    }
    
    return i;
}

- (CGRect)getFrameWithIndex:(int)index {
    int x = 0;
//    int y = index * TIP_HEIGHT + self.topMargin;
    int y = index * TIP_HEIGHT + ([UIScreen mainScreen].bounds.size.height-TIP_HEIGHT) / 2 - 48;
    int width = self.container.frame.size.width;
    int height = TIP_HEIGHT;
    return CGRectMake(x, y, width, height);
}

- (void)updateBubble:(BubbleTipView *)view title:(NSString *)title desc:(NSString *)desc {
    [view update:title desc:desc];
}

- (void)show:(BubbleTipView *)view duration:(NSTimeInterval)duration {
    [self.container addSubview:view];
    [self.showingView insertObject:view atIndex:0];
    
    __weak BubbleTipView *weakV = view;
    
    if (view.needReshow) {
        view.alpha = 0.f;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            __strong UIView *strongV = weakV;
            if (strongV == nil) {
                return;
            }
            
            strongV.alpha = 1.f;
        }];
    }
    
    dispatch_block_t completeBlock = dispatch_block_create(0, ^{
        __strong BubbleTipView *strongV = weakV;
        if (strongV == nil) {
            return;
        }
        
        strongV.blockInvoked = YES;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            strongV.alpha = 0.f;
        } completion:^(BOOL finished) {
            __strong BubbleTipView *strongV = weakV;
            if (strongV == nil) {
                return;
            }
            
            [self recycleView:strongV];
        }];
    });
    view.completeBlock = completeBlock;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration - ANIMATION_DURATION) * NSEC_PER_SEC)), dispatch_get_main_queue(), completeBlock);
}

@end
