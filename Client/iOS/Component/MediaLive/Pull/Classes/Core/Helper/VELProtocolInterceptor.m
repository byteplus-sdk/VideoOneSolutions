// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import  <objc/runtime.h>
#import "VELProtocolInterceptor.h"
static inline BOOL vel_is_sel_belongs_protocol(SEL sel, Protocol * pro) {
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));
        struct objc_method_description hasMethod = protocol_getMethodDescription(pro, sel, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }
    return NO;
}
@interface VELProtocolInterceptor ()
@property (nonatomic, strong) NSArray <Protocol *> *protocols;
@end
@implementation VELProtocolInterceptor
- (instancetype)initWithdProtocol:(Protocol *)protocol {
    self = [super init];
    if (self) {
        _protocols = @[protocol];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.interceptor respondsToSelector:aSelector] &&
        [self isInterceptorRespondsSelector:aSelector]) {
        return self.interceptor;
    }

    if ([self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }

    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.interceptor respondsToSelector:aSelector] &&
        [self isInterceptorRespondsSelector:aSelector]) {
        return YES;
    }

    if ([self.receiver respondsToSelector:aSelector]) {
        return YES;
    }

    return [super respondsToSelector:aSelector];
}

- (BOOL)isInterceptorRespondsSelector:(SEL)aSelector {
    __block BOOL isSelectorContainedInInterceptedProtocols = NO;
    [self.protocols enumerateObjectsUsingBlock:^(Protocol * protocol, NSUInteger idx, BOOL *stop) {
        isSelectorContainedInInterceptedProtocols = vel_is_sel_belongs_protocol(aSelector, protocol);
        * stop = isSelectorContainedInInterceptedProtocols;
    }];
    return isSelectorContainedInInterceptedProtocols;
}

@end
