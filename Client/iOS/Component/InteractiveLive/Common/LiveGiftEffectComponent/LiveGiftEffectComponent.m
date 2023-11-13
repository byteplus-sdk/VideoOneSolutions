// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftEffectComponent.h"
#import "GCDTimer.h"
#import "LiveGiftTrackView.h"
#import <Foundation/Foundation.h>

@interface LiveGiftEffectComponent ()

@property (nonatomic, strong) UIView *LiveGiftEffectContentView;

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, copy) NSArray<LiveGiftTrackView *> *LiveGiftTrackViewQueue;

@property (nonatomic, strong) LiveGiftTrackView *track1;

@property (nonatomic, strong) LiveGiftTrackView *track2;

@end

@implementation LiveGiftEffectComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
        [_superView addSubview:self.LiveGiftEffectContentView];
        [self.LiveGiftEffectContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(222, 96));
            make.left.mas_equalTo(_superView).offset(12);
            make.bottom.mas_equalTo(_superView).offset(-([DeviceInforTool getVirtualHomeHeight] + 249));
        }];
    }
    return self;
}
- (void)addTrackToQueue:(LiveGiftEffectModel *)model {
    LiveGiftTrackView *track = [[LiveGiftTrackView alloc] initWithModel:model withDuration:4];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.LiveGiftTrackViewQueue];
    [mutableArray addObject:track];
    self.LiveGiftTrackViewQueue = [mutableArray copy];
    if (self.LiveGiftTrackViewQueue.count == 1) {
        [self showTrack];
    }
}

- (void)setTrack1:(LiveGiftTrackView *)track1 {
    _track1 = track1;
}

- (void)setTrack2:(LiveGiftTrackView *)track2 {
    _track2 = track2;
}

#pragma mark - private Actions
- (void)showTrack {
    CGFloat trackWidth = 222;
    CGFloat trackHeight = 44;
    if (self.track1 == nil) {
        if (self.LiveGiftTrackViewQueue.count > 0) {
            self.track1 = self.LiveGiftTrackViewQueue[0];
            [self.LiveGiftEffectContentView addSubview:self.track1];
            [self.track1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(trackWidth, trackHeight));
                make.left.mas_equalTo(self.LiveGiftEffectContentView).offset(-trackWidth);
                make.bottom.mas_equalTo(self.LiveGiftEffectContentView);
            }];

            [UIView animateWithDuration:0.5 animations:^{
                self.track1.transform = CGAffineTransformMakeTranslation(trackWidth, 0);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeTrack:@"track1"];
            });
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.LiveGiftTrackViewQueue];
            [mutableArray removeObjectAtIndex:0];
            self.LiveGiftTrackViewQueue = [mutableArray copy];
        }
    }
    if (self.track2 == nil) {
        if (self.LiveGiftTrackViewQueue.count > 0) {
            self.track2 = self.LiveGiftTrackViewQueue[0];
            [self.LiveGiftEffectContentView addSubview:self.track2];
            [self.track2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(trackWidth, trackHeight));
                make.left.mas_equalTo(self.LiveGiftEffectContentView).offset(-trackWidth);
                make.top.mas_equalTo(self.LiveGiftEffectContentView);
            }];

            [UIView animateWithDuration:0.5 animations:^{
                self.track2.transform = CGAffineTransformMakeTranslation(trackWidth, 0);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeTrack:@"track2"];
            });
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.LiveGiftTrackViewQueue];
            [mutableArray removeObjectAtIndex:0];
            self.LiveGiftTrackViewQueue = [mutableArray copy];
        }
    }
}

- (void)hidden:(BOOL)isHidden {
    self.LiveGiftEffectContentView.hidden = isHidden;
}

- (void)removeTrack:(NSString *)trackName {
    if ([trackName isEqual:@"track1"]) {
        if (self.track1.superview) {
            [self.track1 removeFromSuperview];
        }
        self.track1 = nil;
    } else {
        if (self.track2.superview) {
            [self.track2 removeFromSuperview];
        }
        self.track2 = nil;
    }
    [self showTrack];
}

#pragma mark - Getter

- (UIView *)LiveGiftEffectContentView {
    if (!_LiveGiftEffectContentView) {
        _LiveGiftEffectContentView = [[UIView alloc] init];
        _LiveGiftEffectContentView.backgroundColor = [UIColor clearColor];
    }
    return _LiveGiftEffectContentView;
}

- (NSArray<LiveGiftTrackView *> *)LiveGiftTrackViewQueue {
    if (!_LiveGiftTrackViewQueue) {
        _LiveGiftTrackViewQueue = [[NSArray alloc] init];
    }
    return _LiveGiftTrackViewQueue;
}

@end
