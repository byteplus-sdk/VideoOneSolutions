// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDTTVideoEngineSourceCategory.h"
#import <objc/message.h>

@implementation TTVideoEngineVidSource (MDVidSource)

#pragma mark - Setter && getter

- (void)setStartTime:(NSInteger)startTime {
    objc_setAssociatedObject(self, @selector(startTime), @(startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)startTime {
    return [objc_getAssociatedObject(self, @selector(startTime)) integerValue];
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

- (void)setCover:(NSString *)cover {
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cover {
    return objc_getAssociatedObject(self, @selector(cover));
}

@end


@implementation TTVideoEngineUrlSource (MDUrlSource)

#pragma mark - Setter && getter

- (void)setStartTime:(NSInteger)startTime {
    objc_setAssociatedObject(self, @selector(startTime), @(startTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)startTime {
    return [objc_getAssociatedObject(self, @selector(startTime)) integerValue];
}

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

- (void)setCover:(NSString *)cover {
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cover {
    return objc_getAssociatedObject(self, @selector(cover));
}

@end
