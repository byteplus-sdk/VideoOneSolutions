// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceProgressElement.h"
#import "Masonry.h"
#import "VEPlayerUIModule.h"
#import <ToolKit/VEInterfaceFactory.h>
#import <ToolKit/ToolKit.h>

NSString *const progressViewId = @"progressViewId";

NSString *const progressGestureId = @"progressGestureId";

@interface VEInterfaceProgressElement ()

@property (nonatomic, weak) VEEventPoster *eventPoster;

@end

@implementation VEInterfaceProgressElement

@synthesize elementID;
@synthesize type;

#pragma mark----- VEInterfaceElementProtocol

- (id)elementAction:(id)mayElementView {
    if ([mayElementView isKindOfClass:[VEProgressView class]]) {
        VEProgressView *progressView = (VEProgressView *)mayElementView;
        return @{VEPlayEventSeek: @(progressView.currentValue)};
    } else {
        return VEPlayEventProgressValueIncrease;
    }
}

- (void)elementNotify:(id)mayElementView key:(NSString *)key obj:(id)obj {
    if ([mayElementView isKindOfClass:[VEProgressView class]]) {
        VEProgressView *progressView = (VEProgressView *)mayElementView;
        BOOL screenIsClear = [self.eventPoster screenIsClear];
        BOOL screenIsLocking = [self.eventPoster screenIsLocking];
        if ([key isEqualToString:VEPlayEventTimeIntervalChanged]) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [self.eventPoster duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [self.eventPoster playableDuration];
                progressView.hidden = (progressView.totalValue >= 60) ? NO : YES;
                VEInterface *interface = (VEInterface *)progressView.superview.superview.superview;
                if ([interface isKindOfClass:[VEInterface class]]) {
                    UILabel *subtitleLabel = [interface viewWithTag:VEInterfaceSubtitleTag];
                    NSInteger height = 12;
                    if ([interface.delegate respondsToSelector:@selector(interfaceBottomHeightForSubtitle)]) {
                        height = [interface.delegate interfaceBottomHeightForSubtitle];
                    } else {
                        height = progressView.hidden == NO ? 40 : 12;
                    }
                    [subtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                        NSInteger bottom = -height;
                        make.bottom.mas_equalTo(bottom);
                    }];
                }
            };
        } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
            if (!normalScreenBehaivor()) {
                progressView.hidden = screenIsClear;
            }
        } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
            if (!normalScreenBehaivor()) {
                progressView.hidden = screenIsClear;
            }
            progressView.userInteractionEnabled = !screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
}

- (void)elementWillLayout:(UIView *)elementView elementGroup:(NSSet<UIView *> *)elementGroup groupContainer:(UIView *)groupContainer {
    VEProgressView *progressView = (VEProgressView *)elementView;
    progressView.hidden = YES;
    progressView.isHiddenText = YES;
    progressView.currentOrientation = UIInterfaceOrientationPortrait;
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(groupContainer).offset(0);
        make.bottom.equalTo(groupContainer.mas_safeAreaLayoutGuideBottom).offset(0.0);
        make.trailing.equalTo(groupContainer).offset(0);
        make.height.equalTo(@28.0);
    }];
}

#pragma mark----- Element output

+ (VEInterfaceElementDescriptionImp *)progressViewWithEventPoster:(id)eventPoster {
    @autoreleasepool {
        VEInterfaceProgressElement *element = [VEInterfaceProgressElement new];
        element.eventPoster = eventPoster;
        element.type = VEInterfaceElementTypeProgressView;
        element.elementID = progressViewId;
        return element.elementDescription;
    }
}

+ (VEInterfaceElementDescriptionImp *)progressGesture {
    @autoreleasepool {
        return ({
            VEInterfaceElementDescriptionImp *progressGestureDes = [VEInterfaceElementDescriptionImp new];
            progressGestureDes.elementID = progressGestureId;
            progressGestureDes.type = VEInterfaceElementTypeGestureHorizontalPan;
            progressGestureDes.elementAction = ^NSString *(id sender) {
                return VEPlayEventProgressValueIncrease;
            };
            progressGestureDes;
        });
    }
}

@end
