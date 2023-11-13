// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BytedEffectProtocol.h"

@interface BytedEffectProtocol ()

@property (nonatomic, strong) id<BytedEffectDelegate> bytedEffectDelegate;

@end

@implementation BytedEffectProtocol

- (instancetype)initWithRTCEngineKit:(id)rtcEngineKit useCache:(BOOL)useCache {
    //Open source code does not support beauty related functions, please download Demo to experience the effect
    NSObject<BytedEffectDelegate> *effectBeautyComponent = [[NSClassFromString(@"EffectBeautyComponent") alloc] init];
    if (effectBeautyComponent) {
        self.bytedEffectDelegate = effectBeautyComponent;
    }

    if ([self.bytedEffectDelegate respondsToSelector:@selector(protocol:initWithRTCEngineKit:useCache:)]) {
        return [self.bytedEffectDelegate protocol:self
                             initWithRTCEngineKit:rtcEngineKit
                                         useCache:useCache];
    } else {
        return nil;
    }
}

- (void)showWithView:(UIView *)superView
        dismissBlock:(void (^)(BOOL result))block {
    if ([self.bytedEffectDelegate respondsToSelector:@selector(protocol:showWithView:dismissBlock:)]) {
        [self.bytedEffectDelegate protocol:self
                              showWithView:superView
                              dismissBlock:block];
    }
}

- (void)resume {
    if ([self.bytedEffectDelegate respondsToSelector:@selector(protocol:resume:)]) {
        [self.bytedEffectDelegate protocol:self
                                    resume:YES];
    }
}

- (void)reset {
    if ([self.bytedEffectDelegate respondsToSelector:@selector(protocol:reset:)]) {
        [self.bytedEffectDelegate protocol:self
                                     reset:YES];
    }
}

@end
