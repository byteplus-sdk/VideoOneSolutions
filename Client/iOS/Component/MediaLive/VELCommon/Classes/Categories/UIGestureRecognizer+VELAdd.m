// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIGestureRecognizer+VELAdd.h"
#import <objc/runtime.h>
@interface UIGestureRecognizerTarget : NSObject
@property(nonatomic, copy) void (^actionBlock)(id sender);
@end
@implementation UIGestureRecognizerTarget
- (instancetype)initWithBlock:(void (^)(id sender))block{
    if (self = [super init]) {
        self.actionBlock = block;
    }
    return self;
}
- (void)gestureAction:(id)sender {
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}
@end

@implementation UIGestureRecognizer (VELAdd)
- (instancetype)initWithActionBlock:(void (^)(id sender))block {
    if (self = [self init]) {
        [self addTargetWithBlock:block];
    }
    return self;
}

- (void)addTargetWithBlock:(void (^)(id sender))block {
    UIGestureRecognizerTarget *target = [[UIGestureRecognizerTarget alloc] initWithBlock:block];
    [self.allTargets addObject:target];
        [self addTarget:target
                 action:@selector(gestureAction:)];
}

static char kAssociatedObjectKey_allTargets;
- (void)setAllTargets:(NSMutableArray *)allTargets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_allTargets, allTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)allTargets {
    NSMutableArray *targets = (NSMutableArray *)objc_getAssociatedObject(self, &kAssociatedObjectKey_allTargets);
    if (targets == nil) {
        targets = [NSMutableArray arrayWithCapacity:10];
        [self setAllTargets:targets];
    }
    return targets;
}
@end
