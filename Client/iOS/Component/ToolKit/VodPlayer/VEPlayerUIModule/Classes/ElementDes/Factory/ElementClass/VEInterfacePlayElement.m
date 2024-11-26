// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfacePlayElement.h"
#import "Masonry.h"
#import "VEEventConst.h"
#import "VEPlayerUIModule.h"
#import <ToolKit/ToolKit.h>

NSString *const playButtonId = @"playButtonId";

NSString *const playGestureId = @"playGestureId";

NSString *const likeGestureId = @"likeGestureId";

@interface VEInterfacePlayElement ()

@property (nonatomic, weak) VEEventPoster *eventPoster;

@end

@implementation VEInterfacePlayElement

@synthesize elementID;
@synthesize type;

#pragma mark----- VEInterfaceElementProtocol
- (NSString *)elementAction:(id)mayElementView {
    VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
    if (playbackState == VEPlaybackStatePlaying) {
        return VEPlayEventPause;
    } else {
        return VEPlayEventPlay;
    }
}
- (void)elementNotify:(id)mayElementView key:(NSString *)key obj:(id)obj {
    if (self.type == VEInterfaceElementTypeButton) {
        VEActionButton *button = (VEActionButton *)mayElementView;
        if ([key isEqualToString:VEPlayEventStateChanged]) {
            VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
            VOLogI(VOToolKit, @"elementNotify, playbackState:%ld", playbackState);
            button.hidden = playbackState != VEPlaybackStatePaused;
        }
    }
}
- (id)elementSubscribe:(id)mayElementView {
    return VEPlayEventStateChanged;
}
- (void)elementWillLayout:(UIView *)elementView elementGroup:(NSSet<UIView *> *)elementGroup groupContainer:(UIView *)groupContainer {
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(groupContainer);
        make.size.equalTo(@(CGSizeMake(80.0, 80.0)));
    }];
}
- (void)elementDisplay:(VEActionButton *)button {
    [button setImage:[UIImage imageNamed:@"video_play" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
    VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
    button.hidden = YES;
}

#pragma mark----- Element output

+ (VEInterfaceElementDescriptionImp *)playButtonWithEventPoster:(VEEventPoster *)eventPoster {
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
        return ({
            VEInterfaceElementDescriptionImp *gestureDes = [VEInterfaceElementDescriptionImp new];
            gestureDes.elementID = playGestureId;
            gestureDes.type = VEInterfaceElementTypeGestureSingleTap;
            __weak typeof(eventPoster) weak_poster = eventPoster;
            gestureDes.elementAction = ^NSString *(id sender) {
                VOLogI(VOToolKit, @"elementAction, getsture");
                VEPlaybackState playbackState = [weak_poster currentPlaybackState];
                if (playbackState == VEPlaybackStatePlaying) {
                    return VEPlayEventPause;
                } else {
                    return VEPlayEventPlay;
                }
            };
            gestureDes;
        });
    }
}

+ (VEInterfaceElementDescriptionImp *)likeGesture {
    @autoreleasepool {
        return ({
            VEInterfaceElementDescriptionImp *gestureDes = [VEInterfaceElementDescriptionImp new];
            gestureDes.elementID = likeGestureId;
            gestureDes.type = VEInterfaceElementTypeGestureDoubleTap;
            gestureDes.elementAction = ^NSString *(id sender) {
                return VEUIEventLikeVideo;
            };
            gestureDes;
        });
    }
}

@end
