// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BytedEffectProtocol.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>

@interface BytedEffectProtocol ()

@property (nonatomic, strong) id<BytedEffectComponentDelegate> bytedEffectDelegate;

@end

@implementation BytedEffectProtocol

- (instancetype) initWithEngine:(id)engine
            withType:(EffectType)type
                useCache:(BOOL)useCache {
    //Open source code does not support beauty related functions, please download Demo to experience the effect
    NSObject<BytedEffectComponentDelegate> *effectBeautyComponent;
    if (type == EffectTypeRTC) {
        effectBeautyComponent = [[NSClassFromString(@"RTCEffectManager") alloc] init];
    } else if (type == EffectTypeMediaLive) {
       effectBeautyComponent = [[NSClassFromString(@"LiveEffectManager") alloc] init];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:@"unknown effect type"];
        return nil;
    }
    
    if (effectBeautyComponent) {
        self.bytedEffectDelegate = effectBeautyComponent;
        return [self.bytedEffectDelegate protocol:self initWithEngine:engine useCache:useCache];
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"not_support_beauty_error", @"ToolKit")];
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
