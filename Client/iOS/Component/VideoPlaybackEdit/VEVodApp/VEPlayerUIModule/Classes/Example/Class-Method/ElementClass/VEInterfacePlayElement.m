// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfacePlayElement.h"
#import "VEPlayerUIModule.h"
#import "Masonry.h"

NSString *const playButtonId = @"playButtonId";

NSString *const playGestureId = @"playGestureId";

@interface VEInterfacePlayElement ()

@property (nonatomic, strong) VEEventPoster *eventPoster;

@end

@implementation VEInterfacePlayElement

@synthesize elementID;
@synthesize type;

#pragma mark ----- VEInterfaceElementProtocol

- (NSString *)elementAction:(id)mayElementView {
    VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
    if (playbackState == VEPlaybackStatePlaying) {
        return VEPlayEventPause;
    } else {
        return VEPlayEventPlay;
    }
}

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj {
    if (self.type == VEInterfaceElementTypeButton) {
        VEActionButton *button = (VEActionButton *)mayElementView;
        BOOL screenIsClear = [self.eventPoster screenIsClear];
        BOOL screenIsLocking = [self.eventPoster screenIsLocking];
        if ([key isEqualToString:VEPlayEventStateChanged]) {
            VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
            button.hidden = playbackState == VEPlaybackStatePlaying;
            button.selected = playbackState != VEPlaybackStatePlaying;
        } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
            button.hidden = screenIsLocking ?: screenIsClear;
        } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
            button.hidden = screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    if (self.type == VEInterfaceElementTypeButton) {
        return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
    } else {
        return VEPlayEventStateChanged;
    }
}

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer {
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(groupContainer);
        make.size.equalTo(@(CGSizeMake(80.0, 80.0)));
    }];
}

- (void)elementDisplay:(VEActionButton *)button {
    [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
}

#pragma mark ----- Element output

+ (VEInterfaceElementDescriptionImp *)playButtonWithEventPoster:(VEEventPoster *)eventPoster{
    @autoreleasepool {
        VEInterfacePlayElement *element = [VEInterfacePlayElement new];
        element.eventPoster = eventPoster;
        element.type = VEInterfaceElementTypeButton;
        element.elementID = playButtonId;
        return element.elementDescription;
    }
}

+ (VEInterfaceElementDescriptionImp *)playGestureWithEventPoster:(VEEventPoster *)eventPoster {
    @autoreleasepool {
        VEInterfacePlayElement *element = [VEInterfacePlayElement new];
        element.eventPoster = eventPoster;
        element.type = VEInterfaceElementTypeGestureSingleTap;
        element.elementID = playGestureId;
        return element.elementDescription;
    }
}

@end
