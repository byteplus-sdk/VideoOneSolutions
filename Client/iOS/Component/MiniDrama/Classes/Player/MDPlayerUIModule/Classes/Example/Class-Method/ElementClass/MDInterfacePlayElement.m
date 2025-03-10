// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfacePlayElement.h"
#import "MDPlayerUIModule.h"
#import <Masonry/Masonry.h>

NSString *const mdplayButtonId = @"mdplayButtonId";

NSString *const mdplayGestureId = @"mdplayGestureId";

@implementation MDInterfacePlayElement

@synthesize elementID;
@synthesize type;

#pragma mark ----- MDInterfaceElementProtocol

- (NSString *)elementAction:(id)mayElementView {
    MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
    if (playbackState == MDPlaybackStatePlaying) {
        return MDPlayEventPause;
    } else {
        return MDPlayEventPlay;
    }
}

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj {
    if (self.type == MDInterfaceElementTypeButton) {
        MDActionButton *button = (MDActionButton *)mayElementView;
        BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
        BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
        if ([key isEqualToString:MDPlayEventStateChanged]) {
            MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
            button.hidden = playbackState == MDPlaybackStatePlaying;
            button.selected = playbackState != MDPlaybackStatePlaying;
        } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
            button.hidden = screenIsLocking ?: screenIsClear;
        } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
            button.hidden = screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    if (self.type == MDInterfaceElementTypeButton) {
        return @[MDPlayEventStateChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
    } else {
        return MDPlayEventStateChanged;
    }
}

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer {
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(groupContainer);
        make.size.equalTo(@(CGSizeMake(80.0, 80.0)));
    }];
}

- (void)elementDisplay:(MDActionButton *)button {
    [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
}

#pragma mark ----- Element output

+ (MDInterfaceElementDescriptionImp *)playButton {
    @autoreleasepool {
        MDInterfacePlayElement *element = [MDInterfacePlayElement new];
        element.type = MDInterfaceElementTypeButton;
        element.elementID = mdplayButtonId;
        return element.elementDescription;
    }
}

+ (MDInterfaceElementDescriptionImp *)playGesture {
    @autoreleasepool {
        MDInterfacePlayElement *element = [MDInterfacePlayElement new];
        element.type = MDInterfaceElementTypeGestureSingleTap;
        element.elementID = mdplayGestureId;
        return element.elementDescription;
    }
}

@end
