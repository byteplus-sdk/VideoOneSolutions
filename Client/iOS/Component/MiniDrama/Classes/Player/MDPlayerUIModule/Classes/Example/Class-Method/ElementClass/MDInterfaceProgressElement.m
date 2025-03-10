// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceProgressElement.h"
#import "MDPlayerUIModule.h"
#import <Masonry/Masonry.h>

NSString *const mdprogressViewId = @"mdprogressViewId";

NSString *const mdprogressGestureId = @"mdprogressGestureId";

@implementation MDInterfaceProgressElement

@synthesize elementID;
@synthesize type;

#pragma mark ----- MDInterfaceElementProtocol

- (id)elementAction:(id)mayElementView {
    if ([mayElementView isKindOfClass:[MDProgressView class]]) {
        MDProgressView *progressView = (MDProgressView *)mayElementView;
        return @{MDPlayEventSeek : @(progressView.currentValue)};
    } else {
        return MDPlayEventProgressValueIncrease;
    }
}

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj {
    if ([mayElementView isKindOfClass:[MDProgressView class]]) {
        MDProgressView *progressView = (MDProgressView *)mayElementView;
        BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
        BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
        if ([key isEqualToString:MDPlayEventTimeIntervalChanged]) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [[MDEventPoster currentPoster] duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [[MDEventPoster currentPoster] playableDuration];
            };
        } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
            progressView.hidden = screenIsLocking ?: screenIsClear;
        } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
            progressView.hidden = screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    return @[MDPlayEventTimeIntervalChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
}

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer {
    MDProgressView *progressView = (MDProgressView *)elementView;
    progressView.currentOrientation = UIInterfaceOrientationPortrait;
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(groupContainer).offset(12.0);
        make.bottom.equalTo(groupContainer).offset(-50.0);
        make.trailing.equalTo(groupContainer).offset(-12.0);
        make.height.equalTo(@50.0);
    }];
}


#pragma mark ----- Element output

+ (MDInterfaceElementDescriptionImp *)progressView {
    @autoreleasepool {
        MDInterfaceProgressElement *element = [MDInterfaceProgressElement new];
        element.type = MDInterfaceElementTypeProgressView;
        element.elementID = mdprogressViewId;
        return element.elementDescription;
    }
}

+ (MDInterfaceElementDescriptionImp *)progressGesture {
    @autoreleasepool {
        MDInterfaceProgressElement *element = [MDInterfaceProgressElement new];
        element.type = MDInterfaceElementTypeGestureHorizontalPan;
        element.elementID = mdprogressGestureId;
        return element.elementDescription;
    }
}

@end
